//
//  signer-base.h
//  SignerSupport
//
//  Created by Kabir Oberai on 10/10/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

#ifndef signer_base_h
#define signer_base_h

#include <stdio.h>

#pragma clang assume_nonnull begin

#ifdef __cplusplus
extern "C" {
#endif

typedef struct entitlements_data {
    const char *bundle_path;
    const void *data;
    size_t len;
} entitlements_data_t;

// on failure, returns non-zero and populate `*exception`
typedef int(*sign_func)(
    const char *app_directory,
    const void *cert_data,
    size_t cert_len,
    const void *private_key_data,
    size_t private_key_len,
    const entitlements_data_t *entitlements,
    size_t num_entitlements,
    void (*progress)(const void *, double),
    const void *progressContext,
    // must be freed if non-NULL
    char * _Nullable * _Nonnull exception
);

// the returned value must be freed
// on failure, returns null and populates `*exception`
typedef void * _Nullable (*analyze_func)(
    const char *path,
    size_t *out_len,
    char * _Nullable * _Nonnull exception
);

typedef struct signer {
    const char *name;
    sign_func sign;
    analyze_func analyze;
    struct signer * _Nullable next;
} signer_t;

void add_signer(const char *name, sign_func sign, analyze_func analyze);
signer_t * _Nullable get_signers(void);

#ifdef __cplusplus
}
#endif

#pragma clang assume_nonnull end

#endif /* signer_base_h */
