import json
import os
import re
import argparse
from tqdm import tqdm
from generator import Generator
from chunker import LongchatChunker
from fastchat.model import load_model

def load_testcases(test_file):
    with open(test_file, 'r') as json_file:
        json_list = list(json_file)

    test_cases = []
    for test_case in json_list:
        test_case = json.loads(test_case)
        test_cases.append(test_case)

    return test_cases

def test_lines_one_sample(model, tokenizer, test_case):
    chunker = LongchatChunker()
    generator = Generator(model=model, tokenizer=tokenizer, chunker=chunker)
    output = generator.generate([test_case["prompt"]], max_tokens=100)
    # Matching the last digit of the model output
    response_number = re.findall("\d+", output)
    if response_number is not None and len(response_number) > 0:
        response_number = int(response_number[-1])
    else:
        print(f"Got unparsable result")
        response_number = -1

    prompt_length = tokenizer(chunker.get_org_full_prompt(test_case['prompt']), return_tensors="pt").input_ids.shape[-1]
    summary = (f"Label: {test_case['expected_number']},",
               f" Predict: {output}, Parsed: {response_number},",
               f" prompt length: {prompt_length}").replace('\n', ' ')
    print(summary)
    

def main(args, model, tokenizer):
    for num_lines in [300]:
        print(f"************ Start testing {num_lines} lines per LRT prompt ************")
        test_file = os.path.join(args.test_dir, f"lines/testcases/{num_lines}_lines.jsonl")
        
        num_correct = 0
        avg_length = 0

        test_cases = load_testcases(test_file)
        for idx, test_case in tqdm(enumerate(test_cases)):
            correct, prompt_length, summary = test_lines_one_sample(model=model, tokenizer=tokenizer, test_case=test_case)
            avg_length += prompt_length / len(test_cases)
            num_correct += correct
            break
        accuracy = num_correct / len(test_cases)

        print(f"************ Finish testing {num_lines} lines per prompt with average prompt length {avg_length}, accuracy: {accuracy} ************")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model-name-or-path", type=str, help="model path", default="/rscratch/zhendong/lily/longchat-7b-16k/")
    parser.add_argument("--test_dir", type=str, default="/home/eecs/zhen/lily/LongChat/longeval/evaluation", help="Directory of the testcases")
    parser.add_argument("--num_gpus", type=int, default=1, help="number of gpus to use")
    parser.add_argument("--max_gpu_memory", type=int, default=40, help="max per gpu memory in GiB. A100 is 40 or 80.")
    
    args = parser.parse_args()
    model, tokenizer = load_model(
            args.model_name_or_path,
            device="cuda",
            num_gpus=args.num_gpus,
            max_gpu_memory=f"{args.max_gpu_memory}GiB",
            load_8bit=False,
            cpu_offloading=False,
            debug=False,
        )
    from llama_condense_monkey_patch import replace_llama_with_condense
    longchat_ratio = 8
    replace_llama_with_condense(longchat_ratio)

    main(args, model, tokenizer)