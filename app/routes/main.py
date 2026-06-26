from flask import Blueprint, render_template, request, redirect, session
from app.models import db, Product

bp = Blueprint("main", __name__)

@bp.route("/")
def login():
    return render_template("login.html")

@bp.route("/login", methods=["POST"])
def do_login():
    if request.form["username"] == "admin" and request.form["password"] == "1234":
        session["user"] = "admin"
        return redirect("/dashboard")
    return "Login Failed"

@bp.route("/dashboard")
def dashboard():
    if "user" not in session:
        return redirect("/")

    search = request.args.get("search")

    if search:
        products = Product.query.filter(Product.name.contains(search)).all()
    else:
        products = Product.query.all()

    return render_template("dashboard.html", products=products)

@bp.route("/add", methods=["POST"])
def add():
    name = request.form["name"]
    qty = int(request.form["qty"])

    p = Product(name=name, qty=qty)
    db.session.add(p)
    db.session.commit()

    return redirect("/dashboard")
