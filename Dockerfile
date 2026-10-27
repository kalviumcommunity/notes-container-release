# Build stage: install Python dependencies into /install
FROM python:3.12 AS build
WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage
FROM python:3.12
WORKDIR /app
COPY --from=build /install /usr/local
COPY . .
EXPOSE 5000
CMD ["python", "app/app.py"]
