WANDB_PROJECT=specInfer python distill/train.py \
    --student_model_path  JackFram/llama-160m \
    --student_model_path /data/vicuna-7b-v1.3/ \
    --data_path data/gbharti_finance-alpaca_train_with_answer.json \
    --eval_data_path data/gbharti_finance-alpaca_eval.json \
    --bf16 True \
    --output_dir /data/finance_student_fwd \
    --num_train_epochs 2 \
    --per_device_train_batch_size 32 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps 4 \
    --evaluation_strategy "epoch" \
    --save_strategy "steps" \
    --save_steps 100 \
    --save_total_limit 10 \
    --learning_rate 1e-5 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 256 \
    --gradient_checkpointing True \
    --lazy_preprocess True \
    --run_name finance_student_fwd \
    --mode offline \
    --sample_source student \
    --kl_method forward

mkdir output
python distill/experiment/compare_model.py \
       --data /home/lily/spec_new/data/gbharti_finance-alpaca_eval.json \
       --student /data/finance_student_fwd   > output/finance_student_fwd_acc.out