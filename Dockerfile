FROM itzg/minecraft-server

# Add a simple health check page
RUN echo '<?php echo "OK"; ?>' > /var/www/html/health.php
