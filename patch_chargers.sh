grep -rl "	}" charger/ | grep -v "err != nil" | xargs -I{} echo "Fixing {}..."
