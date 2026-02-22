FROM httpd:2.4

# Copy your local website files into the container's web root
COPY . /usr/local/apache2/htdocs/

# Expose port 80
EXPOSE 80
