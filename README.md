# 3scale-sso-oidc-integration

## Prerequisites

3Scale is installed using the operator
Keycloak is installed using the operator

This repository expects both 3Scale and SSO are installed in the same Project or Namespace

## SET Variables

`export NAMESPACE=<PROJECT_OR_NAMESPACE>`
`export SSO_HOST=<SSO_HOST>`

`source ./env`

## Keycloack (RH-SSO) setup

`kubectl apply -rf keycloak/`

Manual Step:

1-Login to Keycloack.

2-Select Client Zync in Realm 3Scale

3-Click on Service Account Roles Tab

4-From Client Roles DropDown select relam-management

5- In the Available Roles Box Select manage-clients and then click Add selected


## Integrate Keycloak (RH-SSO) with 3Scale

`./sso-integration.sh`

## 3Scale Configuration

`kubectl apply -rf 3scale/`

`( echo "cat << EOF"; cat animals-product-oidc-sso.yml ; echo EOF ) | sh | kubectl apply -f - -n $NAMESPACE`

Manual Steps:

Create an application for user Aly under Red Hat org, and select Product Animals

On the Products page, make sure to promote your product to Stage or Prod.

## License
Apache 2.0
