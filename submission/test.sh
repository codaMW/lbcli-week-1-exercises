#!/bin/bash

# Import helper functions
source submission/functions.sh

# Week One Exercise: Bitcoin Address Generation and Transaction Verification
# This script demonstrates using the key concepts from previous exercises in a practical scenario

# Ensure script fails fast on errors
set -e

# ========================================================================
# STUDENT EXERCISE PART BEGINS HERE - Complete the following sections
# ========================================================================

# Set up the challenge scenario
setup_challenge

# CHALLENGE PART 1: Create a wallet to track your discoveries
echo "CHALLENGE 1: Create your explorer wallet"
echo "----------------------------------------"
echo "Create a wallet named 'btrustwallet' to track your Bitcoin exploration"
# STUDENT TASK: Use bitcoin-cli to create a wallet named "btrustwallet"
bitcoin-cli -regtest createwallet "btrustwallet" false
# Ensure wallet is HD-enabled and has a keypool
bitcoin-cli -regtest -rpcwallet=btrustwallet walletcreatefundedpsbt "[]" "[]" 0 "{\"replaceable\":true}" | grep -q "psbt" || bitcoin-cli -regtest -rpcwallet=btrustwallet sethdseed true
bitcoin-cli -regtest -rpcwallet=btrustwallet keypoolrefill 100

# Create a second wallet that will hold the treasure
echo "Now, create another wallet called 'treasurewallet' to fund your adventure"
# STUDENT TASK: Create another wallet called "treasurewallet"
bitcoin-cli -regtest createwallet "treasurewallet" false
bitcoin-cli -regtest -rpcwallet=treasurewallet sethdseed true
bitcoin-cli -regtest -rpcwallet=treasurewallet keypoolrefill 100

# Generate an address for mining in the treasure wallet
# STUDENT TASK: Generate a new address in the treasurewallet
TREASURE_ADDR=$(bitcoin-cli -regtest -rpcwallet=treasurewallet getnewaddress)
check_cmd "Address generation"
echo "Mining to address: $TREASURE_ADDR"

# Mine some blocks to get initial coins
mine_blocks 101 $TREASURE_ADDR

# CHALLENGE PART 2: Check your starting balance
echo ""
echo "CHALLENGE 2: Check your starting resources"
echo "-----------------------------------------"
echo "Check your wallet balance to see what resources you have to start"
# STUDENT TASK: Get the balance of btrustwallet
BALANCE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getbalance)
check_cmd "Balance check"
echo "Your starting balance: $BALANCE BTC"

# CHALLENGE PART 3: Generate different address types to collect treasures
echo ""
echo "CHALLENGE 3: Create a set of addresses for your exploration"
echo "---------------------------------------------------------"
echo "The treasure hunt requires 4 different types of addresses to collect funds."
echo "Generate one of each address type (legacy, p2sh-segwit, bech32, bech32m)"
# STUDENT TASK: Generate addresses of each type
LEGACY_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" legacy)
check_cmd "Legacy address generation"

P2SH_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" p2sh-segwit)
check_cmd "P2SH address generation"

SEGWIT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32)
check_cmd "SegWit address generation"

TAPROOT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32m)
check_cmd "Taproot address generation"

echo "Your exploration addresses:"
echo "- Legacy treasure map: $LEGACY_ADDR"
echo "- P2SH ancient vault: $P2SH_ADDR"
echo "- SegWit digital safe: $SEGWIT_ADDR"
echo "- Taproot quantum vault: $TAPROOT_ADDR"

# This part is done for you - sending treasures to each address
echo ""
echo "The treasure hunt begins! Coins are being sent to your addresses..."

# Send treasure to each address using our helper function with fee handling
send_with_fee "treasurewallet" "$LEGACY_ADDR" 1.0 "First clue: Verify this transaction"
send_with_fee "treasurewallet" "$P2SH_ADDR" 2.0 "Second clue: Needs validation"
send_with_fee "treasurewallet" "$SEGWIT_ADDR" 3.0 "Third clue: Check descriptor"
send_with_fee "treasurewallet" "$TAPROOT_ADDR" 4.0 "Final clue: Message verification"

# Mine blocks to confirm the transactions
mine_blocks 6 $TREASURE_ADDR

# CHALLENGE PART 4: Find the total treasure collected
echo ""
echo "CHALLENGE 4: Count your treasures"
echo "-------------------------------"
echo "Treasures have been sent to your addresses. Check how much you've collected!"
# STUDENT TASK: Check wallet balance after receiving funds and calculate how much treasure was collected
NEW_BALANCE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getbalance)
check_cmd "New balance check"
echo "Your treasure balance: $NEW_BALANCE BTC"

COLLECTED=$(echo "$NEW_BALANCE - $BALANCE" | bc)
check_cmd "Balance calculation"
echo "You've collected $COLLECTED BTC in treasures!"

# CHALLENGE PART 5: Validate that one of your addresses is valid
echo ""
echo "CHALLENGE 5: Validate the ancient vault address"
echo "--------------------------------------------"
echo "To ensure the P2SH vault is secure, verify it's a valid Bitcoin address"
# STUDENT TASK: Validate the P2SH address
P2SH_VALID=$(bitcoin-cli -regtest -rpcwallet=btrustwallet validateaddress "$P2SH_ADDR" | jq -r '.isvalid')
check_cmd "Address validation"
echo "P2SH vault validation: $P2SH_VALID"

if [[ "$P2SH_VALID" == "true" ]]; then
  echo "Vault is secure! You may proceed to the next challenge."
else
  echo "WARNING: Vault security compromised!"
  exit 1
fi

# CHALLENGE PART 6: Decode a signed message to reveal a secret
echo ""
echo "CHALLENGE 6: Decode the hidden message"
echo "------------------------------------"
echo "You've found a message signed with the legacy address key."
echo "Verify the signature to reveal the hidden message!"

# This part is done for you - creating a signed message
SECRET_MESSAGE="You've successfully completed the Bitcoin treasure hunt!"
SIGNATURE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet signmessage "$LEGACY_ADDR" "$SECRET_MESSAGE")
check_cmd "Message signing"
echo "Address: $LEGACY_ADDR"
echo "Signature: $SIGNATURE"

# For interactive learning, students would guess the message:
echo "In an interactive environment, you would guess the message content."
echo "For CI testing, we'll verify the correct message directly:"

# STUDENT TASK: Verify the message
VERIFY_RESULT=$(bitcoin-cli -regtest -rpcwallet=btrustwallet verifymessage "$LEGACY_ADDR" "$SIGNATURE" "$SECRET_MESSAGE")
check_cmd "Message verification"
echo "Message verification result: $VERIFY_RESULT"

if [[ "$VERIFY_RESULT" == "true" ]]; then
  echo "Message verified successfully! The secret message is:"
  echo "\"$SECRET_MESSAGE\""
else
  echo "ERROR: Message verification failed!"
  exit 1
fi

# CHALLENGE PART 7: Working with descriptors to find the final treasure
echo ""
echo "CHALLENGE 7: The descriptor treasure map"
echo "-------------------------------------"
echo "The final treasure is locked with an address derived from a descriptor."
echo "Create a descriptor for your taproot address and derive the address to ensure it matches."

# STUDENT TASK: Create a new taproot address
NEW_TAPROOT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32m)
check_cmd "New taproot address generation"
NEW_TAPROOT_ADDR=$(trim "$NEW_TAPROOT_ADDR")

# Ensure the wallet has an HD seed and sufficient keypool
bitcoin-cli -regtest -rpcwallet=btrustwallet sethdseed true 2>/dev/null || true
bitcoin-cli -regtest -rpcwallet=btrustwallet keypoolrefill 100

# Ensure the address has a corresponding key by checking for a private key
MAX_ATTEMPTS=3
for ((i=1; i<=MAX_ATTEMPTS; i++)); do
  PRIV_KEY=$(bitcoin-cli -regtest -rpcwallet=btrustwallet dumpprivkey "$NEW_TAPROOT_ADDR" 2>/dev/null)
  if [ -n "$PRIV_KEY" ]; then
    break
  else
    echo "Warning: No private key found for Taproot address (Attempt $i/$MAX_ATTEMPTS). Regenerating address..."
    NEW_TAPROOT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32m)
    check_cmd "Regenerated taproot address (Attempt $i)"
    NEW_TAPROOT_ADDR=$(trim "$NEW_TAPROOT_ADDR")
  fi
done

if [ -z "$PRIV_KEY" ]; then
  echo "Error: Failed to generate a Taproot address with a private key after $MAX_ATTEMPTS attempts."
  exit 1
fi

# STUDENT TASK: Get the address info to extract the internal key
ADDR_INFO=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getaddressinfo "$NEW_TAPROOT_ADDR")
check_cmd "Getting address info"

# STUDENT TASK: Extract the internal key (the x-only pubkey) from the address info
INTERNAL_KEY=$(echo "$ADDR_INFO" | jq -r '.pubkey // ""')
check_cmd "Extracting key from address info"
INTERNAL_KEY=$(trim "$INTERNAL_KEY")

# Validate the internal key
if [ -z "$INTERNAL_KEY" ] || [ "$INTERNAL_KEY" == "null" ]; then
  echo "Error: No valid pubkey found for Taproot address. Wallet may be misconfigured."
  echo "Debug: ADDR_INFO = $ADDR_INFO"
  exit 1
fi

# Debug: Verify the key length (x-only pubkey should be 32 bytes / 64 hex chars)
KEY_LENGTH=$(echo -n "$INTERNAL_KEY" | xxd -r -p | wc -c)
if [ "$KEY_LENGTH" -ne 32 ]; then
  echo "Error: Invalid x-only pubkey length ($KEY_LENGTH bytes, expected 32). Exiting."
  exit 1
fi

# STUDENT TASK: Create a proper descriptor with just the key
echo "Using internal key: $INTERNAL_KEY"
SIMPLE_DESCRIPTOR="tr($INTERNAL_KEY)"
echo "Simple descriptor: $SIMPLE_DESCRIPTOR"

# STUDENT TASK: Get a proper descriptor with checksum
TAPROOT_DESCRIPTOR=$(bitcoin-cli -regtest getdescriptorinfo "$SIMPLE_DESCRIPTOR" | jq -r '.descriptor')
check_cmd "Descriptor generation"
TAPROOT_DESCRIPTOR=$(trim "$TAPROOT_DESCRIPTOR")
echo "Taproot treasure map: $TAPROOT_DESCRIPTOR"

# STUDENT TASK: Derive an address from the descriptor
DERIVED_ADDR_RAW=$(bitcoin-cli -regtest deriveaddresses "$TAPROOT_DESCRIPTOR")
check_cmd "Address derivation"
DERIVED_ADDR=$(echo "$DERIVED_ADDR_RAW" | tr -d '[]" \n\t')
echo "Derived quantum vault address: $DERIVED_ADDR"

# Verify the addresses match
echo "New taproot address: $NEW_TAPROOT_ADDR"
echo "Derived address:     $DERIVED_ADDR"

# Debug output to help diagnose any issues
echo "Address lengths: ${#NEW_TAPROOT_ADDR} vs ${#DERIVED_ADDR}"
echo "Address comparison (base64 encoded to see any hidden characters):"
echo "New:     $(echo -n "$NEW_TAPROOT_ADDR" | base64)"
echo "Derived: $(echo -n "$DERIVED_ADDR" | base64)"

if [[ "$NEW_TAPROOT_ADDR" == "$DERIVED_ADDR" ]]; then
  echo "Addresses match! The final treasure is yours!"

  # For educational purposes, show both addresses from the challenge
  echo ""
  echo "Note: In Bitcoin Core v28, the original taproot address used in the challenge was:"
  echo "Original address: $TAPROOT_ADDR"
  echo "This wasn't used in our final verification to ensure consistency with v28."
else
  echo "ERROR: Address mismatch detected! The derived address does not match the taproot address."
  echo "This indicates an issue with the descriptor derivation process."
  echo "New taproot address: $NEW_TAPROOT_ADDR"
  echo "Derived address:     $DERIVED_ADDR"
  exit 1
fi

# CHALLENGE COMPLETE
echo ""
echo "TREASURE HUNT COMPLETE!"
echo "======================="
show_wallet_info "btrustwallet"
echo ""
echo "Congratulations on completing the Bitcoin treasure hunt!"
echo "You've successfully used Bitcoin Core to:"
echo "- Create a wallet"
echo "- Generate different address types"
echo "- Track and verify balances"
echo "- Validate addresses"
echo "- Work with message signatures"
echo "- Use Bitcoin descriptors"
echo ""
echo "NOTE: This script is specifically designed to work with Bitcoin Core v28."
