## Basic repro
```bash
rm -rf x509-cert-example/orchestrator
mkdir x509-cert-example/orchestrator
cd x509-cert-example/orchestrator
cp ../../local-testnet/example/utxo-keys/utxo1.skey ./orchestrator.skey
cp ../../local-testnet/example/utxo-keys/utxo1.vkey ./orchestrator.vkey
cardano-cli address build --testnet-magic 42 --payment-verification-key-file orchestrator.vkey > orchestrator.addr
```

```bash
cardano-cli transaction policyid --script-file ../../assets/V3/coldAlwaysTrueMint.plutus > coldAlwaysTrueMint.pol
cardano-cli address build --testnet-magic 42 --payment-script-file ../../assets/V3/coldLockScript.plutus > coldLockScript.addr
cardano-cli conway query protocol-parameters --testnet-magic 42 --out-file pp.json
```


### Failing one:
create transaction:
```bash
 cardano-cli conway transaction build --testnet-magic 42 \
 --tx-in "$(cardano-cli query utxo --address "$(cat orchestrator.addr)" --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in-collateral "$(cardano-cli query utxo --address "$(cat orchestrator.addr)" --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --mint "1 $(cat coldAlwaysTrueMint.pol).4964656e74697479204e4654" \
 --tx-out $(cat coldLockScript.addr)+5000000 \
 --tx-out-inline-datum-file ../../assets/datums/initColdLockScriptDatum.json \
 --change-address $(cat orchestrator.addr) \
 --mint-script-file ../../assets/V3/coldAlwaysTrueMint.plutus --mint-redeemer-value {} \
 --out-file tx.fail
```
submit a transaction:
```bash
cardano-cli transaction sign --testnet-magic 42 --signing-key-file orchestrator.skey --tx-body-file tx.fail --out-file tx.signed
cardano-cli transaction submit --testnet-magic 42 --tx-file tx.signed
```

### Succeeding one:
```bash
 cardano-cli conway transaction build --testnet-magic 42 \
 --tx-in "$(cardano-cli query utxo --address "$(cat orchestrator.addr)" --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in-collateral "$(cardano-cli query utxo --address "$(cat orchestrator.addr)" --testnet-magic 42 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --mint "1 $(cat coldAlwaysTrueMint.pol).4964656e74697479204e4654" \
 --tx-out $(cat coldLockScript.addr)+5000000+"1 $(cat coldAlwaysTrueMint.pol).4964656e74697479204e4654" \
 --tx-out-inline-datum-file ../../assets/datums/initColdLockScriptDatum.json \
 --change-address $(cat orchestrator.addr) \
 --mint-script-file ../../assets/V3/coldAlwaysTrueMint.plutus --mint-redeemer-value {} \
 --out-file tx.success
```
submit a transaction:
```bash
cardano-cli transaction sign --testnet-magic 42 --signing-key-file orchestrator.skey --tx-body-file tx.fail --out-file tx.signed
cardano-cli transaction submit --testnet-magic 42 --tx-file tx.signed
```
