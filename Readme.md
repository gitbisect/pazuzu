### Pazuzu
## Pazuzu will tag your attached ebs volumes with the names of the servers (if they have a Name tag)

Pazuzu can take as input a region name e.g. us-west-1, us-east-1


### Next steps
If you want to improve pazuzu here are some pointers.
1. Try and fetch only the volumes that are not already tagged. You just need to make the filter work properly.
1. Try and name the volumes even if the instances are not tagged with Name.