FROM python:3.11-slim

WORKDIR /app

COPY . .

RUN pip install --index-url https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

CMD ["python", "app.py"]
