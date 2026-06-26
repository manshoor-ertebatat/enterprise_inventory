from flask import Blueprint, render_template, request, redirect, session
from app.models import db, Product, Movement, User
from openpyxl import Workbook
from flask import send_file
import io

bp = Blueprint("main", __name__)

@bp.route("/")
def login():
    return render_template("login.html")

@bp.route("/login", methods=["POST"])
def do_login():

    username = request.form["username"]
    password = request.form["password"]

    user = User.query.filter_by(
        username=username,
        password=password
    ).first()

    if user:

        session["user"] = user.username
        session["role"] = user.role

        return redirect("/dashboard")

    return "نام کاربری یا رمز عبور اشتباه است"

@bp.route("/dashboard")
def dashboard():

    if "user" not in session:
        return redirect("/")

    search = request.args.get("search")

    if search:
        products = Product.query.filter(
            Product.name.contains(search)
        ).all()
    else:
        products = Product.query.all()

    movements = Movement.query.order_by(
        Movement.id.desc()
    ).limit(10).all()

    total_products = len(products)

    low_stock = len([
        p for p in products
        if p.qty > 0 and p.qty < 5
    ])

    out_of_stock = len([
        p for p in products
        if p.qty == 0
    ])

    return render_template(
        "dashboard.html",
        products=products,
        movements=movements,
        total_products=total_products,
        low_stock=low_stock,
        out_of_stock=out_of_stock
    )

@bp.route("/add", methods=["POST"])
def add():
    name = request.form["name"]
    qty = int(request.form["qty"])

    p = Product(name=name, qty=qty)
    db.session.add(p)
    db.session.commit()

    return redirect("/dashboard")

@bp.route("/move", methods=["POST"])
def move():
    product_id = int(request.form["product_id"])
    qty = int(request.form["qty"])
    mtype = request.form["type"]
    receiver_name = request.form.get(
        "receiver_name",
        ""
    )

    customer_name = request.form.get(
        "customer_name",
        ""
    )

    description = request.form.get(
        "description",
        ""
    )

    product = Product.query.get(product_id)

    if mtype == "OUT" and product.qty < qty:
        return "Not enough stock"

    if mtype == "IN":
        product.qty += qty
    else:
        product.qty -= qty

    m = Movement(
        product_id=product_id,
        qty=qty,
        type=mtype,
        receiver_name=receiver_name,
        customer_name=customer_name,
        description=description
    )
    db.session.add(m)
    db.session.commit()

    return redirect("/dashboard")

@bp.route("/logout")
def logout():

    session.clear()

    return redirect("/")

@bp.route("/delete/<int:id>")
def delete_product(id):

    if "user" not in session:
        return redirect("/")

    product = Product.query.get(id)

    if product:
        db.session.delete(product)
        db.session.commit()

    return redirect("/dashboard")

    return redirect("/dashboard")

@bp.route("/edit/<int:id>", methods=["GET","POST"])
def edit_product(id):

    if "user" not in session:
        return redirect("/")

    product = Product.query.get(id)

    if request.method == "POST":

        product.name = request.form["name"]
        product.qty = int(request.form["qty"])

        db.session.commit()

        return redirect("/dashboard")

    return render_template(
        "edit_product.html",
        product=product
    )

@bp.route("/export_excel")
def export_excel():

    if "user" not in session:
        return redirect("/")

    wb = Workbook()
    ws = wb.active

    ws.title = "Inventory"

    ws.append([
        "ID",
        "Product Name",
        "Quantity"
    ])

    products = Product.query.all()

    for p in products:
        ws.append([
            p.id,
            p.name,
            p.qty
        ])

    output = io.BytesIO()

    wb.save(output)

    output.seek(0)

    return send_file(
        output,
        as_attachment=True,
        download_name="inventory.xlsx",
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
