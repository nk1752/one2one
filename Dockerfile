# syntax=docker/dockerfile:1.2

FROM python:3.10.2-buster

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

# Install pyodbc dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev libffi-dev \
    python3-pip python3-dev \
    tdsodbc \
    unixodbc-dev \
    freetds-dev \
    curl
ADD odbcinst.ini /etc/odbcinst.ini

# Install the Microsoft ODBC driver for SQL Server (Linux)
# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15
RUN apt-get update && apt-get install -y apt-transport-https 
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install msodbcsql17 --assume-yes

# Add path
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile 
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc 

# Setup DIR
WORKDIR /app
COPY . .

# Install pyodbc and other packages
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]