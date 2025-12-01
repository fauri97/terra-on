<template>
  <dialog v-if="open" class="modal modal-open">
    <div class="modal-box max-w-lg">
      <h3 class="font-bold text-lg mb-1">Editar usuário</h3>
      <p class="text-xs text-base-content/60 mb-4">Ajuste os dados e permissões deste usuário.</p>

      <form class="space-y-4" @submit.prevent="onSubmit">
        <!-- Linha 1: Nome / Telefone -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
          <label class="form-control w-full">
            <span class="label-text text-xs font-medium">Nome</span>
            <input
              v-model="form.name"
              type="text"
              class="input input-bordered input-sm w-full"
              required
            />
          </label>

          <label class="form-control w-full">
            <span class="label-text text-xs font-medium">Telefone</span>
            <input
              v-model="form.phoneNumber"
              type="text"
              class="input input-bordered input-sm w-full"
            />
          </label>
        </div>

        <!-- Linha 2: E-mail (full width) -->
        <div>
          <label class="form-control w-full">
            <span class="label-text text-xs font-medium">E-mail</span>
            <input
              v-model="form.email"
              type="email"
              class="input input-bordered input-sm w-full"
              required
              disabled
            />
          </label>
        </div>

        <!-- Linha 3: Cidade / Estado -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
          <label class="form-control w-full">
            <span class="label-text text-xs font-medium">Cidade</span>
            <input v-model="form.city" type="text" class="input input-bordered input-sm w-full" />
          </label>

          <label class="form-control w-full">
            <span class="label-text text-xs font-medium">Estado</span>
            <input v-model="form.state" type="text" class="input input-bordered input-sm w-full" />
          </label>
        </div>

        <!-- Linha 4: Perfil -->
        <div>
          <label class="form-control w-full">
            <span class="label-text text-xs font-medium">Perfil</span>
            <select v-model="form.role" class="select select-bordered select-sm w-full">
              <option value="User">User</option>
              <option value="Gov">Gov</option>
              <option value="Admin">Admin</option>
            </select>
          </label>
        </div>

        <!-- Ações -->
        <div class="modal-action mt-2">
          <button
            type="button"
            class="btn btn-ghost btn-sm"
            @click="$emit('close')"
            :disabled="saving"
          >
            Cancelar
          </button>
          <button
            type="submit"
            class="btn btn-primary btn-sm"
            :class="{ loading: saving }"
            :disabled="saving"
          >
            <span v-if="!saving">Salvar alterações</span>
            <span v-else>Salvando...</span>
          </button>
        </div>
      </form>
    </div>

    <!-- Backdrop -->
    <form method="dialog" class="modal-backdrop" @click="$emit('close')">
      <button>close</button>
    </form>
  </dialog>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  open: {
    type: Boolean,
    default: false,
  },
  user: {
    type: Object,
    default: null,
  },
  saving: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['close', 'save'])

const form = ref({
  id: null,
  name: '',
  email: '',
  city: '',
  state: '',
  phoneNumber: '',
  base64ProfileImage: '',
  role: 'User',
})

// sempre que trocar o usuário selecionado ou abrir o modal,
// sincroniza o formulário local
watch(
  () => props.user,
  (u) => {
    if (!u) {
      form.value = {
        id: null,
        name: '',
        email: '',
        city: '',
        state: '',
        phoneNumber: '',
        base64ProfileImage: '',
        role: 'User',
      }
      return
    }

    form.value = {
      id: u.id,
      name: u.name || '',
      email: u.email || '',
      city: u.city || '',
      state: u.state || '',
      phoneNumber: u.phoneNumber || '',
      base64ProfileImage: u.base64ProfileImage || '',
      role: u.role || 'User',
    }
  },
  { immediate: true },
)

const onSubmit = () => {
  if (!form.value.id) return
  emit('save', { ...form.value })
}
</script>
