package com.triptalker.triptalk.global;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

//@Getter
@Data
@AllArgsConstructor
public class BaseResponse<T> {
//    private String message;
    private T data;


}
