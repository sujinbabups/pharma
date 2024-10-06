#!/bin/bash

function createManufacture() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/manufacture.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacture.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-manufacture --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Create the config.yaml file for NodeOUs
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacture.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacture.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacture.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacture.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/config.yaml"

  # Create necessary directories and copy CA certs for MSP definition
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/cacerts"
  cp "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/cacerts/localhost-7054-ca-manufacture.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacture.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacture.example.com/tlsca/tlsca.manufacture.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacture.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacture.example.com/ca/ca.manufacture.example.com-cert.pem"

  # Continue with peer0, user, and admin registration as before...


  # Register peer0
  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-manufacture --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Register user
  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-manufacture --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Register manufacture admin
  echo "Registering the manufacture admin"
  set -x
  fabric-ca-client register --caname ca-manufacture --id.name manufactureadmin --id.secret manufactureadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Generate the peer0 msp
  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacture -M "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null
  cp "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/msp/config.yaml"

  # Generate the peer0-tls certificates
  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacture -M "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls" --enrollment.profile tls --csr.hosts peer0.manufacture.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to known filenames in the peer's tls directory
  cp "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacture.example.com/peers/peer0.manufacture.example.com/tls/server.key"

  # Generate the user msp
  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-manufacture -M "${PWD}/organizations/peerOrganizations/manufacture.example.com/users/User1@manufacture.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null
  cp "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacture.example.com/users/User1@manufacture.example.com/msp/config.yaml"

  # Generate the manufacture admin msp
  echo "Generating the manufacture admin msp"
  set -x
  fabric-ca-client enroll -u https://manufactureadmin:manufactureadminpw@localhost:7054 --caname ca-manufacture -M "${PWD}/organizations/peerOrganizations/manufacture.example.com/users/Admin@manufacture.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacture/ca-cert.pem"
  { set +x; } 2>/dev/null
  cp "${PWD}/organizations/peerOrganizations/manufacture.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacture.example.com/users/Admin@manufacture.example.com/msp/config.yaml"
}



function createDistributor() {
  echo "Enrolling the CA admin for the Distributor"
  mkdir -p organizations/peerOrganizations/distributor.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/distributor.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-distributor --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-distributor.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/distributor.example.com/msp/config.yaml"

  # Copy Distributor's CA cert to its /msp/tlscacerts directory
  mkdir -p "${PWD}/organizations/peerOrganizations/distributor.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem" "${PWD}/organizations/peerOrganizations/distributor.example.com/msp/tlscacerts/ca.crt"

  # Copy Distributor's CA cert to its /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/distributor.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem" "${PWD}/organizations/peerOrganizations/distributor.example.com/tlsca/tlsca.distributor.example.com-cert.pem"

  # Copy Distributor's CA cert to its /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/distributor.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem" "${PWD}/organizations/peerOrganizations/distributor.example.com/ca/ca.distributor.example.com-cert.pem"

  echo "Registering peer0 for the Distributor"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user for the Distributor"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the Distributor admin"
  set -x
  fabric-ca-client register --caname ca-distributor --id.name Distributoradmin --id.secret Distributoradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP for the Distributor"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates for the Distributor"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls" --enrollment.profile tls --csr.hosts peer0.distributor.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy tls files to proper locations
  cp "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/distributor.example.com/peers/peer0.distributor.example.com/tls/server.key"

  echo "Generating the user MSP for the Distributor"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.example.com/users/User1@distributor.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.example.com/users/User1@distributor.example.com/msp/config.yaml"

  echo "Generating the Distributor admin MSP"
  set -x
  fabric-ca-client enroll -u https://Distributoradmin:Distributoradminpw@localhost:8054 --caname ca-distributor -M "${PWD}/organizations/peerOrganizations/distributor.example.com/users/Admin@distributor.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/distributor/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/distributor.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/distributor.example.com/users/Admin@distributor.example.com/msp/config.yaml"
}



function createPharmacy() {
  echo "Enrolling the CA admin for the Pharmacy"
  mkdir -p organizations/peerOrganizations/pharmacy.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/pharmacy.example.com/

  # Enroll the Pharmacy CA admin using the correct port and CA details
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-pharmacy --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-pharmacy.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-pharmacy.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-pharmacy.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-pharmacy.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/pharmacy.example.com/msp/config.yaml"

  # Copy the pharmacy CA cert to its /msp/tlscacerts directory
  mkdir -p "${PWD}/organizations/peerOrganizations/pharmacy.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem" "${PWD}/organizations/peerOrganizations/pharmacy.example.com/msp/tlscacerts/ca.crt"

  # Copy pharmacy CA cert to its /tlsca directory (for clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/pharmacy.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem" "${PWD}/organizations/peerOrganizations/pharmacy.example.com/tlsca/tlsca.pharmacy.example.com-cert.pem"

  # Copy pharmacy CA cert to its /ca directory (for clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/pharmacy.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem" "${PWD}/organizations/peerOrganizations/pharmacy.example.com/ca/ca.pharmacy.example.com-cert.pem"

  echo "Registering peer0 for the Pharmacy"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user for the Pharmacy"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the Pharmacy admin"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name pharmacyadmin --id.secret pharmacyadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP for the Pharmacy"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-pharmacy -M "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pharmacy.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates for the Pharmacy"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-pharmacy -M "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls" --enrollment.profile tls --csr.hosts peer0.pharmacy.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy TLS certificates for peer0 to correct locations
  cp "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/pharmacy.example.com/peers/peer0.pharmacy.example.com/tls/server.key"

  echo "Generating the user MSP for the Pharmacy"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-pharmacy -M "${PWD}/organizations/peerOrganizations/pharmacy.example.com/users/User1@pharmacy.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pharmacy.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pharmacy.example.com/users/User1@pharmacy.example.com/msp/config.yaml"

  echo "Generating the Pharmacy admin MSP"
  set -x
  fabric-ca-client enroll -u https://pharmacyadmin:pharmacyadminpw@localhost:9054 --caname ca-pharmacy -M "${PWD}/organizations/peerOrganizations/pharmacy.example.com/users/Admin@pharmacy.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pharmacy.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pharmacy.example.com/users/Admin@pharmacy.example.com/msp/config.yaml"
}





function createOrderer() {
  echo "Enrolling the CA admin for Orderer"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  # Enroll the CA admin for the orderer using the correct port (9064)
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9064 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9064-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Copy CA certs for the Orderer
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy CA certs to /tlsca directory for Orderer org
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9064 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  echo "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9064 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the TLS CA cert, server cert, server keystore
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy the TLS CA cert to the orderer's MSP directory for MSP definition
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9064 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}



createManufacture
createDistributor
createPharmacy
createOrderer
