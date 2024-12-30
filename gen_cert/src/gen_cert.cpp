#include <gen_cert.h>
#include <openssl_util.h>

#include <iostream>

#include<QString>

GenCertHelper::GenCertHelper(QObject* parent): QObject(parent){}

bool GenCertHelper::genCert(QString pubkey_hex, QString cert_file_path)
{
  std::pair<bool, std::string> ret;
  evp_pkey_shared_ptr sign_pkey = generateSM2Key();
  if(sign_pkey != nullptr) {
    ret = generate_certificate(pubkey_hex.toStdString(), cert_file_path.toStdString(), sign_pkey.get());
  }else {
    return false;
  }

  std::cout << ret.second << std::endl;

  return ret.first;
}
