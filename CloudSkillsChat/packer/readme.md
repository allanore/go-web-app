# Packer Install

## Requirements
- Azure Subscription
- Resource Group named rg-images
- Image shared gallery called sharedImageGallery
- Image called CloudSkillsChat

## Workflow

##### Packer Build

1. The Golang Web App binary and web contents are transfered to the server.
2. Install script is executed.
3. Image is saved and deployed to shared image gallery


##### Install Script
1. Install postgress
2. Create Database and Table with 2 entries.
>**Note**: Postgres table includes an ID column to auto increment the ID number with every new entry. This is because the primary keys must be unique.
3. App folder permissions are set
4. Golang web server set up as a service



