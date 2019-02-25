# Wunder-Wander Gitops
An easy to use GitOps deployment tool for Kubernetes workloads.

## Quality
[![Maintainability](https://api.codeclimate.com/v1/badges/1a75cf1d0c809b33d08f/maintainability)](https://codeclimate.com/github/foldingbeauty/wunder-wander/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1a75cf1d0c809b33d08f/test_coverage)](https://codeclimate.com/github/foldingbeauty/wunder-wander/test_coverage)

## Status

Work in Progress | Proof of Concept

## Why Wunder-Wander Gitops?

TBD

## How to use

- Deploy the Wunder-Wander Gitops controller and CRD:


`$ kubectl apply -f https://raw.githubusercontent.com/foldingbeauty/wunder-wander/master/deployment/deployment.yaml`


- Check if everything is ready to go:

```
$ kubectl get all -n wunderwander-gitops

NAME                                              READY   STATUS    RESTARTS   AGE
pod/gitops-operator-controller-64757768b5-g82jr   1/1     Running   0          22s
pod/gitops-operator-ui-6b978c66bf-5jkcg           1/1     Running   1          22s

NAME                                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gitops-operator-controller   1         1         1            1           24s
deployment.apps/gitops-operator-ui           1         1         1            1           24s

NAME                                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/gitops-operator-controller-64757768b5   1         1         1       24s
replicaset.apps/gitops-operator-ui-6b978c66bf           1         1         1       24s

```

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
  # the name of the CRD + branch name is the name of the namespace
  name: test-app
  namespace: wunderwander-gitops
spec:
  repo: git@github.com:foldingbeauty/wunderwander-test-app.git
  branch: master
```

`$ kubectl apply -f example-gitops-crd.yaml`

When a GitOps resource is deployed, the Wunder-Wander controller will checkout the Git repository and start deploying the contents. 

Wunder-Wander for the Win!
