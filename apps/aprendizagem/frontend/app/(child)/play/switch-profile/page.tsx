import { redirect } from 'next/navigation';

// Trocar perfil = voltar para a selecao de avatar.
export default function SwitchProfilePage() {
  redirect('/select');
}
