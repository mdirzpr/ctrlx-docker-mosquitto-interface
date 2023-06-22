#!/bin/sh

echo copying sme.txt to mount directory
cp /etc/config/sme.txt /etc/sitemanager

echo running SiteManager Embedded
/sitemanager