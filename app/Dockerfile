FROM python:3.10-slim

# Working directory in container
WORKDIR /app

# Copy requirements file & install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the application code
COPY . .

# Expose the port the app runs on
EXPOSE ${PORT}

# Define build-time variables
ARG MONGO_URI
ARG FLASK_ENV

# Set the environment variables
ENV MONGO_URI=${MONGO_URI}
ENV FLASK_ENV=${FLASK_ENV}

# Run the application
CMD ["python", "app.py"]
