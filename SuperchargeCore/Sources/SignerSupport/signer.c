//
//  signer.c
//  Supersign
//
//  Created by Kabir Oberai on 10/10/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

#include <stdlib.h>
#include "signer.h"

signer_t *signer_list = NULL;

void add_signer(const char *name, sign_func sign, analyze_func analyze) {
    signer_t *signer = malloc(sizeof(signer_t));
    *signer = (signer_t) {
        .name = name,
        .sign = sign,
        .analyze = analyze,
        .next = NULL
    };

    if (!signer_list) {
        signer_list = signer;
        return;
    }

    signer_t *last_signer = signer_list;
    while (last_signer->next) last_signer = last_signer->next;
    last_signer->next = signer;
}

signer_t * _Nullable get_signers(void) {
    return signer_list;
}
