import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'c/resourceLoader';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import createPaymentIntent from '@salesforce/apex/GenericStripeController.createPaymentIntent';
import getStripePublicKey from '@salesforce/apex/GenericStripeController.getStripePublicKey';

export default class StripeCardPayment extends LightningElement {
    // API
    @api amount;
    @api result;
    
    // État interne
    @track clientSecret;
    @track publicKey;
    @track initError;
    @track isLoading = false;
    
    @track stripe;
    @track cardElement;
    @track card;
    @track cardErrors;
    @track message;
    @track showModal = false;
    @track showLoader = false;
    @track statusCode;
    @track result;
    
    
    @wire(getStripePublicKey)
    wiredPublicKey({ data, error }) {
        if (data) {
            this.publicKey = data;
            this.tryInitStripe();
        } else if (error) {
            this.initError = 'Erreur récupération clé publique Stripe';
            this.isLoading = false;
            console.error('getStripePublicKey error', error);
        }
    }
    
    @wire(createPaymentIntent, {
        amount: '$amount'
    })
    wiredCreatePaymentIntent({ data, error }) {
        if (data) {
            this.clientSecret = data;
            this.tryInitStripe();
        } else if (error) {
            this.initError = 'Erreur création PaymentIntent Stripe';
            this.isLoading = false;
            console.error('createPaymentIntent error', error);
        }
    }
    
    tryInitStripe() {
        if (this.clientSecret && this.publicKey && !this.cardElement) {
            this.initStripe();
        }
    }
    
    initStripe() {
        this.isLoading = true;
        Promise.all([
            loadScript(this, 'https://js.stripe.com/v3/'),
        ])
        .then(() => {
            const cardElement = this.template.querySelector('.card-element');
            
            if (!cardElement) {
                console.error('Element ".card-element" introuvable dans le template HTML.');
                this.isLoading = false;
                return;
            }
            
            this.stripe = window.Stripe(this.publicKey);
            this.cardElement = cardElement;
            
            const style = {
                base: {
                    color: '#32325d',
                    lineHeight: '18px',
                    fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
                    fontSmoothing: 'antialiased',
                    fontSize: '16px',
                    '::placeholder': {
                        color: '#aab7c4'
                    }
                },
                invalid: {
                    color: '#fa755a',
                    iconColor: '#fa755a'
                }
            };
            
            // const elements = this.stripe.elements({ locale: this.userLanguage });
            const elements = this.stripe.elements();
            this.card = elements.create('card', { style: style, hidePostalCode: true });
            this.card.mount(cardElement);
            
            this.cardErrors = this.template.querySelector('.card-errors');
            this.card.on('change', (event) => this.handleCardChange(event));
            
            this.isLoading = false;
        })
        .catch(error => {
            console.error('Erreur lors du chargement de Stripe.js', error);
            this.initError = 'Erreur lors du chargement de Stripe.js';
            this.isLoading = false;
        });
    }
    
    handleCardChange(event) {
        if (this.cardErrors) {
            this.cardErrors.textContent = event.error ? event.error.message : '';
        }
    }
    
    handlePayment(event) {
        this.showLoader = true;
        this.pay(event);
    }
    
    pay(event) {
        event.preventDefault();
        
        this.stripe.confirmCardPayment(this.clientSecret, {
            payment_method: {
                card: this.card,
                
            },
            setup_future_usage: 'off_session'
        }).then(result => {
            this.showLoader = false;
            
            if (result.error) {
                this.cardErrors.textContent = result.error.message;
                this.message = 'error';
                this.statusCode = result.error.message;
            } else {
                if (result.paymentIntent.status === 'succeeded' || result.paymentIntent.status === 'requires_capture') {
                    this.message = 'success';
                    this.statusCode = '200';
                    this.result  = 'Payment success';
                } else {
                    this.statusCode = result.paymentIntent.status;
                    this.result  = 'Payment failed';
                }
                
            }
        }).then(() => {
            this.handleNext();
        });
    }
    
    closeModal() {
        this.showModal = false;
    }
    
    handleNext(){
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
}