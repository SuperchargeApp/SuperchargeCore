//
//  signer-base.h
//  Supercharge
//
//  Created by Kabir Oberai on 10/10/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

#ifndef signer_base_h
#define signer_base_h

#include <stdio.h>

typedef struct entitlements_data {
    const char *bundle_path;
    const char *data;
    size_t len;
} entitlements_data_t;

// on failure, return non-zero and populate `*exception`
typedef int(*sign_func)(
    const char *app_directory,
    const char *cert_data,
    size_t cert_len,
    const char *private_key_data,
    size_t private_key_len,
    const entitlements_data_t *entitlements,
    size_t num_entitlements,
    void (^progress)(double),
    // must be freed if non-NULL
    char **exception
);

// the returned value must be freed
typedef char *(*analyze_func)(
    const char *path,
    size_t *out_len
);

typedef struct signer {
    const char *name;
    sign_func sign;
    analyze_func analyze;
    struct signer *next;
} signer_t;

#endif /* signer_base_h */
