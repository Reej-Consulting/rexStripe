/**
 * @description       : 
 * @author            : REEJ_AJ
 * @group             : 
 * @last modified on  : 11-12-2025
 * @last modified by  : REEJ_AJ
**/
public with sharing class StripeWebService {

    /**
     * Envoie une requête HTTP à Stripe.
     *
     * @param path   Ex : '/payment_intents'
     * @param method 'GET' ou 'POST'
     * @param params Body JSON envoyé à Stripe (peut être null pour GET)
     */
    private static HttpResponse sendStripeRequest(
        String path,
        String method,
        Map<String, Object> params
    ) {
        // Récupère apiKey + baseUrl 
        Map<String, String> keys = StripeConfigService.getStripeKeys();

        String endpoint = keys.get('baseUrl') + path;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + keys.get('apiKey'));

        if (params != null && !params.isEmpty()) {
             req.setBody(HttpUtils.buildHttpUrl(params));
        }

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Stripe → ' + method + ' ' + endpoint);
        System.debug('Stripe Status → ' + res.getStatusCode());
        System.debug('Stripe Body → ' + res.getBody());

        return res;
    }

    /**
     * Crée un PaymentIntent Stripe et retourne le client_secret.
     *
     * Utilise PaymentIntentRequest :
     *  - amount           : montant en euros
     *  - currencyIsoCode  : devise (ex : 'EUR')
     *  - customerId       : Id client Stripe (facultatif)
     *  - description      : libellé (facultatif)
     */
    public static String createPaymentIntent(PaymentIntentRequest request) {
        // 1) Préparation des paramètres Stripe
        Map<String, Object> params = new Map<String, Object>();

        // Stripe attend un montant entier en centimes → 10.50 € => 1050
        if (request.amount == null) {
            throw new AuraHandledException('Le montant du paiement est obligatoire.');
        }
        String amountInCents = String.valueOf(Integer.valueOf(request.amount * 100));
        params.put('amount', amountInCents);
        params.put('currency', String.isNotBlank(request.currencyIsoCode) ? request.currencyIsoCode : 'EUR');

        // Customer : facultatif 
        if (!String.isBlank(request.customerId)) {
            params.put('customer', request.customerId);
        }

        // Description : facultative
        if (!String.isBlank(request.description)) {
            params.put('description', request.description);
        }

        // 2) Appel Stripe
        HttpResponse res = sendStripeRequest('/payment_intents', 'POST', params);

        if (res != null && res.getStatusCode() == 200) {
            Map<String, Object> body =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) body.get('client_secret');
        }

        // En cas d’erreur → log + retour null
        System.debug('❌ Erreur Stripe createPaymentIntent : ' +
            (res == null ? 'Aucune réponse' : res.getStatusCode() + ' - ' + res.getBody()));

        return null;
    }

}