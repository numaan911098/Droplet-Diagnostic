#!/bin/bash

# Define Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Define services and web apps
services=("nginx" "mysql" "php8.1-fpm" "ssh" "node")
web_apps=("http://localhost/phpmyadmin" "http://localhost/adminer.php" \
          "https://beta-app.leadgenapp.io" "https://beta-api.leadgenapp.io" \
          "https://beta-forms.leadgenapp.io/53aa6c49-5831-48cb-88c2-3704ed0c7971")

# Loading bar animation
loading_bar() {
    echo -ne "${YELLOW}Processing...${RESET}"
    for i in {1..5}; do
        echo -ne "█"
        sleep 0.2
    done
    echo -e "\n"
}

# Check if a service is active
check_services() {
    echo -e "${BLUE}Checking System Services...${RESET}"
    loading_bar
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            echo -e "[${GREEN}✔${RESET}] $service is running."
        else
            echo -e "[${RED}✘${RESET}] $service is NOT running! Restarting..."
            sudo systemctl restart $service && echo -e "[${GREEN}✔${RESET}] $service restarted."
        fi
    done
    echo
}

# Check if web apps are accessible
check_web_apps() {
    echo -e "${BLUE}Checking Web Applications...${RESET}"
    loading_bar
    for url in "${web_apps[@]}"; do
        if curl --output /dev/null --silent --head --fail "$url"; then
            echo -e "[${GREEN}✔${RESET}] $url is accessible."
        else
            echo -e "[${RED}✘${RESET}] $url is NOT accessible! Check the service."
        fi
    done
    echo
}

# Check disk usage
check_disk_usage() {
    echo -e "${BLUE}Checking Disk Usage...${RESET}"
    loading_bar
    df -h | awk '{print $1, $5, $6}' | column -t
    echo
}

# Check CPU load
check_cpu_load() {
    echo -e "${BLUE}Checking CPU Load...${RESET}"
    loading_bar
    uptime | awk '{print "Load Average (1m, 5m, 15m):", $8, $9, $10}'
    echo
}

# Check memory usage
check_memory_usage() {
    echo -e "${BLUE}Checking Memory Usage...${RESET}"
    loading_bar
    free -h | awk '/Mem:/ {print "Total:", $2, "Used:", $3, "Free:", $4}'
    echo
}

# Check active network connections
check_network_connections() {
    echo -e "${BLUE}Checking Network Connectivity...${RESET}"
    loading_bar
    ping -c 4 google.com > /dev/null 2>&1 && \
    echo -e "[${GREEN}✔${RESET}] Internet Connection is Active." || \
    echo -e "[${RED}✘${RESET}] No Internet Connection! Check Network Settings."
    echo
}

# Check Node.js and PHP versions
check_versions() {
    echo -e "${BLUE}Checking Versions...${RESET}"
    loading_bar
    node_version=$(node -v)
    php_version=$(php -v | head -n 1 | awk '{print $2}')
    
    echo -e "[${GREEN}✔${RESET}] Node.js Version: ${node_version}"
    echo -e "[${GREEN}✔${RESET}] PHP Version: ${php_version}"
    
    # Check if required versions match
    if [[ "$node_version" != "v12"* ]]; then
        echo -e "[${RED}✘${RESET}] Node.js version is incorrect! Expected v12.x."
    fi
    
    if [[ "$php_version" != "8.1"* ]]; then
        echo -e "[${RED}✘${RESET}] PHP version is incorrect! Expected 8.1.x."
    fi
    echo
}

# Check Laravel queue workers
check_laravel_queue() {
    echo -e "${BLUE}Checking Laravel Queue Workers...${RESET}"
    loading_bar
    if pgrep -f "php artisan queue:work" > /dev/null; then
        echo -e "[${GREEN}✔${RESET}] Laravel queue workers are running."
    else
        echo -e "[${RED}✘${RESET}] Laravel queue workers are NOT running! Restarting..."
        php /var/www/html/artisan queue:work --daemon &
        echo -e "[${GREEN}✔${RESET}] Laravel queue workers restarted."
    fi
    echo
}

# Check MySQL Database Connection
check_mysql() {
    echo -e "${BLUE}Checking MySQL Database...${RESET}"
    loading_bar
    mysqladmin -u root -p status &> /dev/null && \
    echo -e "[${GREEN}✔${RESET}] MySQL is connected." || \
    echo -e "[${RED}✘${RESET}] MySQL is NOT connected! Check Credentials."
    echo
}

# Main Diagnostic Function
run_diagnostic() {
    echo -e "${GREEN}Linux Droplet Full Diagnostic Tool${RESET}"
    echo -e "${BLUE}====================================${RESET}"
    check_services
    check_web_apps
    check_disk_usage
    check_cpu_load
    check_memory_usage
    check_network_connections
    check_versions
    check_laravel_queue
    check_mysql
    echo -e "${GREEN}Diagnostic Completed!${RESET}"
}

# Execute the diagnostic
run_diagnostic