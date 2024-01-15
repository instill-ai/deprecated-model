import http from 'k6/http';
import encoding from "k6/encoding";
import { check, sleep } from 'k6';

import * as constant from "./const.js"
import * as verify_yolov7 from "./verify-yolov7-stomata.js"

const yolov7_model = "yolov7-stomata";

export const options = {
  setupTimeout: '300s',
  insecureSkipTLSVerify: true,
  thresholds: {
    checks: ["rate == 1.0"],
  },
  // Key configurations for avg load test in this section
  stages: [
    { duration: '30s', target: 10 }, // traffic ramp-up from 1 to 10 users over 30 seconds
    { duration: '15m', target: 10 }, // stay at 10 users for 15 minutes
    { duration: '30s', target: 0 }, // ramp-down to 0 users
  ],
};

export function setup() {
  var loginResp = http.request("POST", `${constant.mgmtPublicHost}/v1beta/auth/login`, JSON.stringify({
    "username": constant.defaultUserId,
    "password": constant.defaultPassword,
  }))

  check(loginResp, {
    [`POST ${constant.mgmtPublicHost}/v1beta/auth/login response status is 200`]: (
      r
    ) => r.status === 200,
  });

  var header = {
    "headers": {
      "Authorization": `Bearer ${loginResp.json().access_token}`
    },
    "timeout": "600s",
  }
  return header
}

export default (header) => {
  // Predict with url
  verify_yolov7.verifyStomataDetection(constant.modelOwner, yolov7_model, "base64", http.request("POST", `${constant.apiHost}/v1alpha/users/${constant.modelOwner}/models/${yolov7_model}/trigger`, JSON.stringify({
    "task_inputs": [{
      "instance_segmentation": {
        "image_base64": encoding.b64encode(constant.stomataImg, "b"),
      },
    }]
  }), header))
};

