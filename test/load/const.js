let proto

export const apiGatewayMode = (__ENV.API_GATEWAY_URL && true);

if (__ENV.API_GATEWAY_PROTOCOL) {
    if (__ENV.API_GATEWAY_PROTOCOL !== "http" && __ENV.API_GATEWAY_PROTOCOL != "https") {
        fail("only allow `http` or `https` for API_GATEWAY_PROTOCOL")
    }
    proto = __ENV.API_GATEWAY_PROTOCOL
} else {
    proto = "http"
}

export const apiHost = `${proto}://${__ENV.API_GATEWAY_URL}/model`
export const mgmtPublicHost = `${proto}://${__ENV.API_GATEWAY_URL}/core`

export const dogImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/dog.jpg`, "b");
export const bearImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/bear.jpg`, "b");

export const streetImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/street.png`, "b");
export const street2Img = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/street2.png`, "b");

export const danceImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/dance.jpg`, "b");
export const dwaynejohnsonImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/dwaynejohnson.jpeg`, "b");

export const signsmallImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/sign-small.jpg`, "b");
export const signpostImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/emergency-evacuation-route-signpost.jpg`, "b");

export const stomataImg = open(`${__ENV.TEST_FOLDER_ABS_PATH}/load/data/sample_stomata.jpg`, "b");

export const modelOwner = "admin"
export const defaultUserId = "admin"
export const defaultPassword = "123123123"
