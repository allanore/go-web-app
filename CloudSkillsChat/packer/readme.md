## Packer Install

#### Requirements
- Azure Subscription
- Resource Group named rg-images
- Image shared gallery called sharedImageGallery
- Image called CloudSkillsChat

#### Important things to note

Postgres table includes an ID column to auto increment the ID number with every new entry. This is because the primary keys must be unique. 

The Golang Web App binary is transfered to the server and set as a service to start.

