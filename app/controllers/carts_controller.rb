class CartsController < ApplicationController

  def checkout
    # We will programatically simulate the last 6 cart items as checkout items
    @items = Cart.order("created_at DESC").limit(6)
    co = Paydunya::Checkout::Invoice.new
    # co.cancel_url = "http://localhost:3000"
    # co.return_url = "http://localhost:3000"
    total_amount = 0.0
    @items.each do | item |
      co.add_item(item.product_name,item.quantity,item.price,item.total_price)
      total_amount += item.total_price
    end
    co.total_amount = total_amount
    if co.create
        redirect_to co.invoice_url
    else
        redirect_to carts_path, :notice => co.response_text
    end
  end

  def request_charge
    # We will programatically simulate the last 6 cart items as checkout items
    @items = Cart.order("created_at DESC").limit(6)
    co = Paydunya::Onsite::Invoice.new
    total_amount = 0.0
    @items.each do | item |
      co.add_item(item.product_name,item.quantity,item.price,item.total_price)
      total_amount += item.total_price
    end
    co.total_amount = total_amount
    if co.create(params[:checkout][:account_alias])
      @token = co.token
    else
      redirect_to root_url, :notice => co.response_text
    end
  end

  def perform_charge
    co = Paydunya::Onsite::Invoice.new
    if co.charge(params[:checkout][:opr_token],params[:checkout][:confirm_token])
      @receipt_url = co.receipt_url
      @message = co.response_text
      @customer_name = co.customer["name"]
    else
      redirect_to root_url, :notice => co.response_text
    end
  end

  def confirmation
    co = Paydunya::Checkout::Invoice.new
    co.confirm(params[:token])
    @result = co
  end

  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @carts }
    end
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
    @cart = Cart.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cart }
    end
  end

  # GET /carts/new
  # GET /carts/new.json
  def new
    @cart = Cart.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cart }
    end
  end

  # GET /carts/1/edit
  def edit
    @cart = Cart.find(params[:id])
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
        format.json { render json: @cart, status: :created, location: @cart }
      else
        format.html { render action: "new" }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /carts/1
  # PUT /carts/1.json
  def update
    @cart = Cart.find(params[:id])

    respond_to do |format|
      if @cart.update_attributes(cart_params)
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart = Cart.find(params[:id])
    @cart.destroy

    respond_to do |format|
      format.html { redirect_to carts_url }
      format.json { head :no_content }
    end
  end

  private

  def cart_params
    params.require(:cart).permit(:price, :product_name, :quantity)
  end
end
