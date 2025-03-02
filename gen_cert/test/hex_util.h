#ifndef _HEXUTIL_H_
#define _HEXUTIL_H_

#include <cstdint>
#include <string>
#include <vector>
#include <memory>

std::string bytesToHexString(const std::vector<uint8_t> buf, char sep);
std::string bytesToHexString(const uint8_t *buf, int len, char sep);
std::vector<uint8_t> hexStringToBytes(const std::string &hexString, char sep);

std::shared_ptr<uint8_t> hexStringToBytes(const std::string &hexString, int *outLen, char sep);

#endif
