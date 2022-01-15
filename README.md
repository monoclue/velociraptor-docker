#### Install with Helm

- `helm add repo https://monoclue.github.io/velociraptor-docker/`
- `helm repo update`
- `kubectl create ns velociraptor`
- `helm install velociraptor velociraptor/velociraptor -n velociraptor`
- Access the Velociraptor GUI via https://\<hostip\>:8889
  - Default u/p is `admin/admin`

#### To Do
- add namespace creation to helm
- move username and password to secret
- enable the use of custom certs