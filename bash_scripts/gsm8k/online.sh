datapath=$1
python distill/train.py \
    --student_model_path JackFram/llama-160m \
    --teacher_model_path  lmsys/vicuna-7b-v1.3 \
    --data_path data/raw_data/gsm8k_train.json \
    --max_propose_num 5 \
    --bf16 True \
    --output_dir $datapath/gsm8k_online \
    --num_train_epochs 1 \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "no" \
    --learning_rate 1e-4 \
    --weight_decay 0. \
    --warmup_ratio 0. \
    --lr_scheduler_type "constant" \
    --tf32 True \
    --model_max_length 256 \
    --gradient_checkpointing False \
    --lazy_preprocess True \
    --run_name gsm8k_online \
    --mode online \
    --online_eval_interval 1 \
    --online_update_interval 8 \
    --logging_steps 1 \
    --logging_nan_inf_filter true