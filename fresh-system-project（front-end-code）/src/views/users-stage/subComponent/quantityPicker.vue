<template>
    <div class="quantity-picker" :class="{ 'is-disabled': disabled }">
        <button class="control-btn decrease" :disabled="isMin" @click="handleChange(-step)" @mousedown.prevent>
            <svg class="icon" viewBox="0 0 24 24">
                <path d="M19 13H5v-2h14v2z" />
            </svg>
        </button>

        <div class="input-container">
            <input type="number" :min="min" :max="max" :value="displayValue" @input="handleInput" @blur="handleBlur"
                @keydown.up.prevent="handleChange(step)" @keydown.down.prevent="handleChange(-step)"
                :disabled="disabled" class="number-input" />
            <div class="value-display">{{ displayValue }}</div>
        </div>

        <button class="control-btn increase" :disabled="isMax" @click="handleChange(step)" @mousedown.prevent>
            <svg class="icon" viewBox="0 0 24 24">
                <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
            </svg>
        </button>
    </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
    modelValue: { type: Number, default: 1 },
    min: { type: Number, default: 1 },
    max: { type: Number, default: Infinity },
    step: { type: Number, default: 1 },
    disabled: Boolean,
    format: { type: Function, default: v => v }
})

const emit = defineEmits(['update:modelValue', 'change'])

const internalValue = ref(props.modelValue)

const isMin = computed(() => internalValue.value <= props.min)
const isMax = computed(() => internalValue.value >= props.max)
const displayValue = computed(() => props.format(internalValue.value))

const handleChange = (delta) => {
    let newValue = internalValue.value + delta
    newValue = Math.max(props.min, Math.min(props.max, newValue))

    if (newValue !== internalValue.value) {
        internalValue.value = newValue
        emit('update:modelValue', newValue)
        emit('change', newValue)
    }
}

const handleInput = (e) => {
    let value = parseInt(e.target.value) || props.min
    value = Math.max(props.min, Math.min(props.max, value))
    internalValue.value = value
    emit('update:modelValue', value)
    emit('change', value)
}

const handleBlur = () => {
    if (internalValue.value < props.min) {
        internalValue.value = props.min
        emit('update:modelValue', props.min)
    }
}
</script>

<style lang="scss">
.quantity-picker {
    --qp-primary: #22A356;
    --qp-bg: #ffffff;
    --qp-border: #e4e7ed;
    --qp-text: #333333;
    --qp-disabled: #f5f7fa;
    --qp-radius: 12px;
    --qp-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    --qp-transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);

    display: inline-flex;
    align-items: center;
    background: var(--qp-bg);
    border-radius: var(--qp-radius);
    box-shadow: var(--qp-shadow);
    transition: var(--qp-transition);

    &:hover:not(.is-disabled) {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    .control-btn {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: none;
        border: none;
        cursor: pointer;
        transition: var(--qp-transition);
        fill: var(--qp-text);

        &:hover:not(:disabled) {
            background: rgba(var(--qp-primary), 0.1);
            fill: var(--qp-primary);
        }

        &:disabled {
            cursor: not-allowed;
            opacity: 0.5;
        }

        &.decrease {
            border-radius: var(--qp-radius) 0 0 var(--qp-radius)
        }

        &.increase {
            border-radius: 0 var(--qp-radius) var(--qp-radius) 0
        }
    }

    .input-container {
        position: relative;
        width: 60px;
        height: 40px;

        .number-input {
            opacity: 0;
            width: 100%;
            height: 100%;
            text-align: center;
            border: none;
            background: transparent;
            

            &::-webkit-outer-spin-button,
            &::-webkit-inner-spin-button {
                -webkit-appearance: none;
            }
        }

        .value-display {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 500;
            color: var(--qp-text);
            pointer-events: none;
        }
    }

    &.is-disabled {
        opacity: 0.7;
        box-shadow: none;
    }
}
</style>