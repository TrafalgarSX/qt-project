#include <cstdint>
#include <hex_util.h>
#include <iostream>
#include <utility>
#include <openssl/ec.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/x509.h>
#include <openssl_util.h>

// 生成 SM2 公私钥对
evp_pkey_shared_ptr generateSM2Key() 
{
  EVP_PKEY_CTX *pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_SM2, NULL);
  if (!pctx) {
    ERR_print_errors_fp(stderr);
    return NULL;
  }

  if (EVP_PKEY_keygen_init(pctx) <= 0) {
    ERR_print_errors_fp(stderr);
    EVP_PKEY_CTX_free(pctx);
    return NULL;
  }

  EVP_PKEY *pkey = NULL;
  if (EVP_PKEY_keygen(pctx, &pkey) <= 0) {
    ERR_print_errors_fp(stderr);
    EVP_PKEY_CTX_free(pctx);
    return NULL;
  }

  EVP_PKEY_CTX_free(pctx);

  evp_pkey_shared_ptr pkey_shared(pkey, EVP_PKEY_free);
  return pkey_shared;
}

EVP_PKEY* create_evp_pkey_from_sm2_pubkey(const unsigned char* pubkey, size_t pubkey_len) 
{
    if (pubkey_len != 64) {
        std::cerr << "Invalid SM2 public key length" << std::endl;
        return nullptr;
    }

    EVP_PKEY* pkey = EVP_PKEY_new();
    if (!pkey) {
        std::cerr << "Failed to create EVP_PKEY" << std::endl;
        return nullptr;
    }

    EC_KEY* ec_key = EC_KEY_new_by_curve_name(NID_sm2);
    if (!ec_key) {
        std::cerr << "Failed to create EC_KEY" << std::endl;
        EVP_PKEY_free(pkey);
        return nullptr;
    }

    BIGNUM* x = BN_bin2bn(pubkey, 32, nullptr);
    BIGNUM* y = BN_bin2bn(pubkey + 32, 32, nullptr);
    if (!x || !y) {
        std::cerr << "Failed to create BIGNUMs from public key" << std::endl;
        EC_KEY_free(ec_key);
        EVP_PKEY_free(pkey);
        return nullptr;
    }

    if (EC_KEY_set_public_key_affine_coordinates(ec_key, x, y) != 1) {
        std::cerr << "Failed to set public key coordinates" << std::endl;
        BN_free(x);
        BN_free(y);
        EC_KEY_free(ec_key);
        EVP_PKEY_free(pkey);
        return nullptr;
    }

    BN_free(x);
    BN_free(y);

    if (EVP_PKEY_assign_EC_KEY(pkey, ec_key) != 1) {
        std::cerr << "Failed to assign EC_KEY to EVP_PKEY" << std::endl;
        EC_KEY_free(ec_key);
        EVP_PKEY_free(pkey);
        return nullptr;
    }

    return pkey;
}

std::pair<bool, std::string> generate_certificate(const std::string& pubkey, const std::string& cert_file, EVP_PKEY* sign_pkey) 
{
    OpenSSL_add_all_algorithms();
    ERR_load_crypto_strings();

    std::vector<uint8_t> pubkey_bytes = hexStringToBytes(pubkey, 0);

    EVP_PKEY* sm2_pkey = create_evp_pkey_from_sm2_pubkey(pubkey_bytes.data(), pubkey_bytes.size());
    evp_pkey_ptr pkey = evp_pkey_ptr(sm2_pkey, EVP_PKEY_free);
    if (!pkey) {
        std::cerr << "Failed to create EVP_PKEY from public key" << std::endl;
        return {false,  "Failed to create EVP_PKEY from public key" };
    }

    // Create a new X.509 certificate
    x509_ptr x509 = x509_ptr(X509_new(), X509_free);
    if (!x509) {
        std::cerr << "Failed to create X.509 certificate" << std::endl;
        return {false, "Failed to create X.509 certificate" };
    }

    // Set the version of the certificate (X509v3)
    X509_set_version(x509.get(), 2);

    // Set the public key for the certificate
    if (!X509_set_pubkey(x509.get(), pkey.get())) {
        std::cerr << "Failed to set public key for X509 certificate" << std::endl;
        return {false, "Failed to set public key for X509 certificate" };
    }

    // Set the subject name
    X509_NAME* name = X509_get_subject_name(x509.get());
    X509_NAME_add_entry_by_txt(name, "C", MBSTRING_ASC, (unsigned char*)"CN", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O", MBSTRING_ASC, (unsigned char*)"wuhan", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (unsigned char*)"sdyx", -1, -1, 0);
    X509_set_issuer_name(x509.get(), name);

    // Set the validity period of the certificate
    X509_gmtime_adj(X509_get_notBefore(x509.get()), 0);
    X509_gmtime_adj(X509_get_notAfter(x509.get()), 31536000L); // 1 year

    // Sign the certificate with the generated private key
    if (!X509_sign(x509.get(), sign_pkey, EVP_sm3())) {
        std::cerr << "Failed to sign certificate" << std::endl;
        return {false, "Failed to sign certificate" };
    }

    // Write the certificate to a file
    FILE* cert_fp = fopen(cert_file.c_str(), "w");
    if (!cert_fp) {
        std::cerr << "Failed to open certificate file" << std::endl;
        return {false, "Failed to open certificate file" };
    }
    PEM_write_X509(cert_fp, x509.get());
    fclose(cert_fp);

    // Clean up
    EVP_cleanup();
    ERR_free_strings();

    return {true, "Certificate created successfully" };
}

#if 0
int main() {
    std::string sign_pubkey = "7F55E9E9E9AC08D03A62D5A27BA94AA8E30910439EE89016D89C8D599ABDDA45C2A4A4997195ED22D1A35B52A02D9DD8CBB8F1140136CFC24E95840A004DA5C8";
    std::string enc_pubkey = "95A36002522F9B0B6BB28027FA58700954239822576C0703FDA9164B2F30BE196FC786363041EA6163B23750B51F804E155A6A9461A359EE80AD9A78AB29C65F";
    std::string sign_cert_file = "sign_cert.pem";
    std::string enc_cert_file = "enc_cert.pem";
    generate_certificate(sign_pubkey, sign_cert_file);
    generate_certificate(enc_pubkey, enc_cert_file);
    return 0;
}
#endif
