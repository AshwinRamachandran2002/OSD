datapath=$1
python distill/train.py \
    --student_model_path $datapath/llama-160m\
    --teacher_model_path $datapath/vicuna-7b-v1.3/ \
    --data_path data/code_search_net_train_with_answer.json \
    --max_propose_num 5 \
    --bf16 True \
    --output_dir $datapath/code_search_net_online_distill\
    --num_train_epochs 0.1 \
    --per_device_train_batch_size 8 \
    --gradient_accumulation_steps 16 \
    --evaluation_strategy "no" \
    --save_strategy "steps" \
    --save_steps 30 \
    --save_total_limit 100 \
    --learning_rate 2e-5 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 512 \
    --gradient_checkpointing True \
    --lazy_preprocess True \
    --run_name code_search_net_online_distill \
    --mode offline \
    --sample_source teacher \
    --kl_method forward \
    --report_to none

WANDB_PROJECT=spec python distill/train.py \
    --student_model_path $datapath/code_search_net_online_distill \
    --teacher_model_path $datapath/vicuna-7b-v1.3/ \
    --data_path data/code_search_net_train.json \
    --max_propose_num 5 \
    --bf16 True \
    --output_dir $datapath/code_search_net_online_baseline\
    --num_train_epochs 1 \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "epoch" \
    --learning_rate 1e-5 \
    --weight_decay 0. \
    --warmup_ratio 0. \
    --lr_scheduler_type "constant" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 512 \
    --gradient_checkpointing True \
    --lazy_preprocess True \
    --run_name code_search_net_online_baseline \
    --mode online \
    --sample_source teacher \
    --kl_method forward \
    --online_eval_interval 1 \
    --online_update_interval 100000 \
    --logging_steps 1 \
    --logging_nan_inf_filter true