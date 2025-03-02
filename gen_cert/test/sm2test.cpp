#include <iostream>
#include <Timer.h>
#include <openssl_util.h>
#include <openssl/evp.h>
#include <thread>
#include <vector>

int sm2_sign(EVP_PKEY* pkey, const unsigned char* data, size_t data_len, unsigned char* sig, size_t* sig_len) {
    if (!pkey || !data || data_len == 0 || !sig || !sig_len) {
        return 0;
    }

    EVP_MD_CTX* md_ctx = EVP_MD_CTX_new();
    if (!md_ctx) {
        return 0;
    }

    if (EVP_DigestSignInit(md_ctx, NULL, EVP_sm3(), NULL, pkey) <= 0) {
        EVP_MD_CTX_free(md_ctx);
        return 0;
    }

    if (EVP_DigestSignUpdate(md_ctx, data, data_len) <= 0) {
        EVP_MD_CTX_free(md_ctx);
        return 0;
    }

    if (EVP_DigestSignFinal(md_ctx, NULL, sig_len) <= 0) {
        EVP_MD_CTX_free(md_ctx);
        return 0;
    }

    if (EVP_DigestSignFinal(md_ctx, sig, sig_len) <= 0) {
        EVP_MD_CTX_free(md_ctx);
        return 0;
    }

    EVP_MD_CTX_free(md_ctx);
    return 1;
}

int sm2_verify(EVP_PKEY* pkey, const unsigned char* data, size_t data_len, const unsigned char* sig, size_t sig_len) {
    if (!pkey || !data || data_len == 0 || !sig || sig_len == 0) {
        return 0;
    }

    EVP_MD_CTX* md_ctx = EVP_MD_CTX_new();
    if (!md_ctx) {
        return 0;
    }

    if (EVP_DigestVerifyInit(md_ctx, NULL, EVP_sm3(), NULL, pkey) <= 0) {
        EVP_MD_CTX_free(md_ctx);
        return 0;
    }

    if (EVP_DigestVerifyUpdate(md_ctx, data, data_len) <= 0) {
        EVP_MD_CTX_free(md_ctx);
        return 0;
    }

    int ret = EVP_DigestVerifyFinal(md_ctx, sig, sig_len);
    EVP_MD_CTX_free(md_ctx);
    return ret;
}

// openssl sm2 sign test
void sm2_sign_test() {
    // generate sm2 key pair
    evp_pkey_shared_ptr sign_key = generateSM2Key();
    EVP_PKEY* pkey = sign_key.get();
    if (!pkey) {
        std::cerr << "Failed to generate SM2 key pair" << std::endl;
        return;
    }

    // sign data
    const char* data = "hello world";
    size_t data_len = strlen(data);

    int thread_count = std::thread::hardware_concurrency();
    std::cout << "thread count: " << thread_count << std::endl;
    int count = 40 * 10000;
    {
        Timer timer;
        std::vector<std::thread> threads;
        for(int i = 0; i < thread_count; i++) {
            threads.push_back(std::thread([&](){
                int loop = count / thread_count;
                std::vector<unsigned char> sig(100, 0);
                size_t sig_len = sig.size();
                // copy pkey
                for (int i = 0; i < loop; i++) {
                    if (!sm2_sign(pkey, (const unsigned char*)data, data_len, sig.data(), &sig_len)) {
                        std::cerr << "Failed to sign data" << std::endl;
                        return;
                    }
                }
            }));
        }

        for(auto& t : threads) {
            t.join();
        }
    }
#if 0
    {
        Timer timer;
        std::vector<std::thread> threads;
        for(int i = 0; i < thread_count; i++) {
            threads.push_back(std::thread([&](){
                int loop = count / thread_count;
                for (int i = 0; i < loop; i++) {
                    // verify signature
                    if (!sm2_verify(pkey, (const unsigned char*)data, data_len, sig, sig_len)) {
                        std::cerr << "Failed to verify signature" << std::endl;
                    } else {
                        // std::cout << "Signature verified" << std::endl;
                    }

                }
            }));
        }
    }
#endif
}


int main(int argc, const char** argv) 
{
    sm2_sign_test();
    return 0;
}