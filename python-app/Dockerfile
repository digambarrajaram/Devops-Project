FROM python:3.9-slim

WORKDIR /app
COPY python-app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

CMD ["python", "app.py"]
