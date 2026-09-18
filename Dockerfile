FROM manshoor-inventory:v1.0.0

WORKDIR /app

COPY app ./app

CMD ["python", "app.py"]
