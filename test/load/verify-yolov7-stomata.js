import {
    check,
} from "k6";


export function verifyStomataDetection(owner, modelID, triggerType, resp) {
    check((resp), {
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response status is 200`]: (r) => r.status === 200,
    });
    check(resp, {
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task`]: (r) => r.json().task === "TASK_INSTANCE_SEGMENTATION",
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs.length`]: (r) => r.json().task_outputs.length === 1,
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].category`]: (r) => r.json().task_outputs[0].instance_segmentation.objects[0].category === "stomata",
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].score`]: (r) => r.json().task_outputs[0].instance_segmentation.objects[0].score > 0.7,
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].rle.length`]: (r) => r.json().task_outputs[0].instance_segmentation.objects[0].rle.length > 0,
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].bounding_box.top`]: (r) => Math.abs(r.json().task_outputs[0].instance_segmentation.objects[0].bounding_box.top - 75) < 5,
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].bounding_box.left`]: (r) => Math.abs(r.json().task_outputs[0].instance_segmentation.objects[0].bounding_box.left - 120) < 5,
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].bounding_box.width`]: (r) => Math.abs(r.json().task_outputs[0].instance_segmentation.objects[0].bounding_box.width - 55) < 5,
        [`POST v1alpha/users/${owner}/models/${modelID}/trigger (${triggerType}) response task_outputs[0].instance_segmentation.objects[0].bounding_box.height`]: (r) => Math.abs(r.json().task_outputs[0].instance_segmentation.objects[0].bounding_box.height - 55) < 5,
    });
}
