# Wunder-Wander Gitops
An easy to use GitOps deployment tool for Kubernetes workloads.

## Quality
[![Maintainability](https://api.codeclimate.com/v1/badges/1a75cf1d0c809b33d08f/maintainability)](https://codeclimate.com/github/foldingbeauty/wunder-wander/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1a75cf1d0c809b33d08f/test_coverage)](https://codeclimate.com/github/foldingbeauty/wunder-wander/test_coverage)

## Status

Work in Progress | Proof of Concept

## How to use

- Create the namespace first:

`$ kubectl apply -f deployment/namespace.yaml`

- Deploy the Wunder-Wander Gitops controller and CRD:

`$ kubectl apply -f deployment`

- Get the SSH Public key and add the key to your Git repository

`$ kubectl get  secret/ssh-keys -n wunderwander-gitops -o jsonpath="{.data.public_key}"| base64 --decode ; echo`

```
ssh-rsa ... ==
```

- Create a Gitops Resource with your Git repository


*example-gitops-crd.yaml*
``` 
apiVersion: "io.wunderwander/v1"
kind: GitOp
metadata:
  name: test
  namespace: wunderwander-gitops
spec:
  repo: git@github.com:foldingbeauty/test-app.git
  branch: master
```

`$ kubectl apply -f example-gitops-crd.yaml`

When a GitOps resource is deployed, the Wunder-Wander controller will checkout the Git repository and start deploying the contents. 

Wunder-Wander for the Win!
