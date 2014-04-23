// -*- mode:c++; tab-width:2; indent-tabs-mode:nil; c-basic-offset:2 -*-

//#ifndef __CHECKSUM_EXCEPTION_H__
#ifndef __CHECKSUM_EXCEPTION_H__
#define __NOT_FOUND_EXCEPTION_H__

/*
 * Copyright 20011 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
///Users/Veritas/梦网科技/企业快快_211/ios_im_client/zxing/cpp/core/src/zxing/ChecksumException.h:5:9: '__NOT_FOUND_EXCEPTION_H__' is defined here; did you mean '__CHECKSUM_EXCEPTION_H__'?//
#include <zxing/ReaderException.h>

namespace zxing {
  class ChecksumException : public ReaderException {
    typedef ReaderException Base;
  public:
    ChecksumException() throw();
    ChecksumException(const char *msg) throw();
    ~ChecksumException() throw();
  };
}

#endif // __CHECKSUM_EXCEPTION_H__
