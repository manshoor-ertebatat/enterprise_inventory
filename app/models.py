from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    username = db.Column(
        db.String(100),
        unique=True
    )

    password = db.Column(
        db.String(255)
    )

    role = db.Column(
        db.String(50)
    )

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120))
    qty = db.Column(db.Integer, default=0)
    has_serial = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Integer, default=1)
    min_qty = db.Column(db.Integer, default=5)
    unit = db.Column(db.String(30), default="عدد")
    category = db.Column(db.String(100), default="سایر")
    condition = db.Column(db.String(50), default="نو")

class Project(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    name = db.Column(
        db.String(200),
        unique=True
    )

    customer = db.Column(
        db.String(200)
    )

    is_active = db.Column(
        db.Integer,
        default=1
    )

class Movement(db.Model):

    id = db.Column(db.Integer, primary_key=True)

    product_id = db.Column(db.Integer)

    type = db.Column(db.String(10))

    qty = db.Column(db.Integer)

    receiver_name = db.Column(db.String(150))

    customer_name = db.Column(db.String(150))

    project_name = db.Column(db.String(200))

    description = db.Column(db.String(500))

    created_by = db.Column(db.String(100))

    timestamp = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

class ActivityLog(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    username = db.Column(
        db.String(100)
    )

    action = db.Column(
        db.String(100)
    )

    description = db.Column(
        db.String(500)
    )

    timestamp = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

class ProductSerial(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    product_id = db.Column(
        db.Integer
    )

    serial_number = db.Column(
        db.String(200),
        unique=True
    )

    status = db.Column(
        db.String(50),
        default="IN_STOCK"
    )

    customer_name = db.Column(
        db.String(150)
    )

    movement_id = db.Column(
        db.Integer
    )

    created_by = db.Column(
        db.String(100)
    )

    timestamp = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

class MaterialRequest(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )


    requester = db.Column(
        db.String(100)
    )

    project_name = db.Column(
        db.String(200)
    )

    description = db.Column(
        db.String(500)
    )

    priority = db.Column(
        db.String(30),
        default="NORMAL"
    )

    location_description = db.Column(
        db.String(1000)
    )

    status = db.Column(
        db.String(30),
        default="PENDING"
    )

    approved_by = db.Column(
        db.String(100)
    )

    approved_at = db.Column(
        db.DateTime
    )

    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )


class MaterialRequestItem(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    request_id = db.Column(
        db.Integer
    )

    product_id = db.Column(
        db.Integer
    )

    qty = db.Column(
        db.Integer
    )

    delivered_qty = db.Column(
        db.Integer,
        default=0
    )

    note = db.Column(
        db.String(300)
    )

class RequestNote(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    request_id = db.Column(
        db.Integer
    )

    note = db.Column(
        db.String(1000)
    )

    created_by = db.Column(
        db.String(100)
    )

    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )
