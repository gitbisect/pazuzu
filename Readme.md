### Pazuzu
## Pazuzu will tag your attached ebs volumes with the names of the servers (if they have a Name tag)

Pazuzu can take as input a single server instance id, or a list of server instance ids - in the future

Right now it will take the output that comes from 
```sh

aws --region us-west-1 ec2 describe-instances
```

and use that to name all the attached volumes of those instances.