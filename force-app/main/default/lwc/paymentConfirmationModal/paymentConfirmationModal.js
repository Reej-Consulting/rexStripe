import { LightningElement, api } from 'lwc';

export default class PaymentConfirmationModal extends LightningElement {
    @api message; 
    @api modalTitle = 'Confirmation de Paiement'; 

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}