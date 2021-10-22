#!/bin/bash                                                                                                                                                  
psql -d ckan_default --csv -c "SELECT p.title, t.running_total, t.recent_views FROM tracking_summary t JOIN package p ON t.package_id = p.id ORDER BY t.running_total DESC LIMIT 10;" | mail -s "CKAN tracking - 10 all-time most-viewed datasets" kwarner@dvrpc.org kkorejko@dvrpc.org jdobkin@dvrpc.org
