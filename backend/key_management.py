import nacl.utils
import base64
import nacl.signing
import nacl.encoding
import nacl.secret

from nacl.signing import VerifyKey
from mnemonic import Mnemonic


def print_info_about_seed_phrase(entropy_bytes):
    entropy_hex = entropy_bytes.hex()
    entropy_base64 = base64.b64encode(entropy_bytes).decode()

    public_key_bytes, secret_key_bytes = nacl.bindings.crypto_box_seed_keypair(
        entropy_bytes)
    public_key_hex = public_key_bytes.hex()
    public_key_base64 = base64.b64encode(public_key_bytes).decode()
    secret_key_hex = secret_key_bytes.hex()
    secret_key_base64 = base64.b64encode(secret_key_bytes).decode()

    signing_key = nacl.signing.SigningKey(entropy_bytes)
    signing_key_bytes = bytes(signing_key)
    signing_key_hex = signing_key_bytes.hex()
    signing_key_base64 = base64.b64encode(signing_key_bytes).decode()

    verify_key_bytes = bytes(signing_key.verify_key)
    verify_key_hex = verify_key_bytes.hex()
    verify_key_base64 = base64.b64encode(verify_key_bytes).decode()

    seed_phrase = mnemo.to_mnemonic(entropy_bytes)

    print(" - Seed phrase:", seed_phrase)
    print("------------------------------------------------")
    print(" - [Crypto Box] Secret key as hex:", secret_key_hex)
    print(" - [Crypto Box] Secret key as base64:", secret_key_base64)
    print("------------------------------------------------")
    print(" - [Crypto Box] Public key as hex:", public_key_hex)
    print(" - [Crypto Box] Public key as base64:", public_key_base64)
    print("------------------------------------------------")
    print(" - [Signing] Secret key as hex:", signing_key_hex)
    print(" - [Signing] Secret key as base64:", signing_key_base64)
    print("------------------------------------------------")
    print(" - [Signing] Public key as hex:", verify_key_hex)
    print(" - [Signing] Public key as base64:", verify_key_base64)
    print("------------------------------------------------")
    print(" - Entropy as hex:", entropy_hex)
    print(" - Entropy as base64:", entropy_base64)
    print("------------------------------------------------")
    print('')
    print('')


def sign_and_verify_sign(entropy_bytes):
    signing_key = nacl.signing.SigningKey(entropy_bytes)

    to_sign = b'2001:db8:1234:4444:9999:6666:7777:9876'
    signed = signing_key.sign(to_sign)
    signed_base64 = base64.b64encode(signed).decode()
    signed_hex = signed.hex()
    print(" - [Signing] Going to sign: ", to_sign)
    print("------------------------------------------------")
    print(" - [Signing] Signed object as hex: ", signed_hex)
    print(" - [Signing] Signed object as base64: ", signed_base64)

    verify_key = signing_key.verify_key
    # verify_key_bytes = verify_key.encode()
    # verify_key = VerifyKey(verify_key_bytes)
    result = verify_key.verify(signed)
    return result


def encrypt_and_decrypt(key):
    box = nacl.secret.SecretBox(key)
    nonce = nacl.utils.random(nacl.secret.SecretBox.NONCE_SIZE)

    to_encrypt = b"Hello world!"

    encrypted = box.encrypt(to_encrypt, nonce)
    encrypted_base64 = base64.b64encode(encrypted).decode()
    encrypted_hex = encrypted.hex()

    print(" - [Encryption] Going to encrypt: ", to_encrypt)
    print("------------------------------------------------")
    print(" - [Encryption] Encrypted as hex: ", encrypted_hex)
    print(" - [Encryption] Encrypted as base64: ", encrypted_base64)
    print("------------------------------------------------")
    plaintext = box.decrypt(encrypted)

    return plaintext


def generate_new_seed_phrase():
    return mnemo.generate(strength=256)


def seed_phrase_to_bytes(seed_phrase):
    return bytes(mnemo.to_entropy(seed_phrase))


print('')
print("============================================")
print("Generating new keypair with strength of 256.")
print("============================================")
print('')

mnemo = Mnemonic("english")

# seed_phrase = generate_new_seed_phrase()
# seed_phrase = "erosion company asset chimney gun uncle vendor grit fit board spoon mushroom argue length notable canal fringe entire basic denial behave eagle spring diet"
# seed_phrase = "forest broom force patient pen rely liar equal leg digital deposit ball scout impact garlic deposit long blade arrange brick tone describe endless slight"
# seed_phrase = "lumber monster ship voice parade pig ill grief wool tiny soon ancient feature ticket muscle birth endorse produce bring armed clean target umbrella sword"
# seed_phrase = "vessel emotion gain fee door face entire artefact badge invite brown hamster puppy guide dune kitten brown video armed close differ sure much reflect"
# base64_encoded_entropy = "oyWgJ9ti0XI/FMbc5pXigoS26ARMYb3YMB7fMvu/HqM="
base64_encoded_entropy = "ZQnIFchAX7j4zSXZhsXCYQLoPEvSGRcuw3DscGC95Uc="
entropy_bytes = base64.b64decode(base64_encoded_entropy)
# entropy_bytes = seed_phrase_to_bytes(seed_phrase)

print_info_about_seed_phrase(entropy_bytes)

print('')
print("============================================")
print("Signing and verifying the sign.")
print("============================================")
print('')

result = sign_and_verify_sign(entropy_bytes)
print("------------------------------------------------")
print(" - [Signing] Sign was successfully validated and returned: ",
      result.decode())

print('')
print("============================================")
print("Encrypting and decrypting the sign.")
print("============================================")
print('')

result = encrypt_and_decrypt(entropy_bytes)
print("------------------------------------------------")
print(" - [Encryption] Successfully encrypted and decrypted: ", result.decode())
# print("Importing seed phrase")
# entropy_bytes2 = seed_phrase_to_bytes(seed_phrase)

# print_info_about_seed_phrase(entropy_bytes2)
