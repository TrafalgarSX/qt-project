#ifndef _OPENSSLUTIL_H_
#define _OPENSSLUTIL_H_

#include <openssl/x509.h>
#include <openssl/evp.h>

#include <string>
#include <utility>
#include <memory>

using evp_pkey_ptr = std::unique_ptr<EVP_PKEY, decltype(&EVP_PKEY_free)>;

using evp_pkey_shared_ptr = std::shared_ptr<EVP_PKEY>;

using x509_ptr = std::unique_ptr<X509, decltype(&X509_free)>;

evp_pkey_shared_ptr generateSM2Key();
std::pair<bool, std::string> generate_certificate(const std::string &pubkey,
                          const std::string &cert_file, EVP_PKEY *sign_pkey);

#endif // _OPENSSLUTIL_H_
