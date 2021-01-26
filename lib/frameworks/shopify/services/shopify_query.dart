class ShopifyQuery {
  static String readCollections = '''
    query {
      shop {
        collections(first: 250) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            node {
              id
              title
              description
              image(maxHeight: 500, maxWidth: 350) {
                id
                src
              }
            }
          }
        }
      }
    }
    ''';

  static String getShop = '''
    query {
    shop {
      name
      description
    }
  }
  ''';

  static String getProducts = '''
    query(\$cursor: String, \$pageSize: Int) {
      shop {
        name
        description
        products(first: \$pageSize, after: \$cursor) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              title
              vendor
              description
              availableForSale
              productType
              onlineStoreUrl
              collections(first: 1) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    id
                  }
                }
              }
              options {
                id
                name
                values
              }
              variants(first: 250) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    id
                    title
                    availableForSale
                    selectedOptions {
                      name
                      value
                    }
                    image(maxHeight: 500, maxWidth: 350) {
                      src
                    }
                    price
                    compareAtPrice
                  }
                }
              }
              images(first: 250, maxHeight: 500, maxWidth: 350) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    src
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String getProductByName = '''
    query(\$cursor: String, \$pageSize: Int, \$query: String) {
      shop {
        name
        description
        products(first: \$pageSize, after: \$cursor, query: \$query) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              title
              vendor
              description
              availableForSale
              productType
              onlineStoreUrl
              collections(first: 1) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    id
                  }
                }
              }
              options {
                id
                name
                values
              }
              variants(first: 250) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    id
                    title
                    availableForSale
                    selectedOptions {
                      name
                      value
                    }
                    image(maxHeight: 500, maxWidth: 350) {
                      src
                    }
                    price
                    compareAtPrice
                    priceV2 {
                      amount
                      currencyCode
                    }
                    compareAtPriceV2 {
                      amount
                      currencyCode
                    }
                  }
                }
              }
              images(first: 250, maxHeight: 500, maxWidth: 350) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    src
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
  static String getProductById = '''
   query(\$id: ID!) {
    node(id: \$id) {
    ...on Product {
      id
      title
      vendor
      description
      availableForSale
      productType
      onlineStoreUrl
      collections(first: 1) {
        pageInfo {
          hasNextPage
          hasPreviousPage
        }
        edges {
          node {
            id
          }
        }
      }
      options {
        id
        name
        values
      }
      variants(first: 250) {
        pageInfo {
          hasNextPage
          hasPreviousPage
        }
        edges {
          node {
            id
            title
            availableForSale
            selectedOptions {
              name
              value
            }
            image(maxHeight: 500, maxWidth: 350) {
              src
            }
            price
            compareAtPrice
            priceV2 {
              amount
              currencyCode
            }
            compareAtPriceV2 {
              amount
              currencyCode
            }
          }
        }
      }
      images(first: 250, maxHeight: 500, maxWidth: 350) {
        pageInfo {
          hasNextPage
          hasPreviousPage
        }
        edges {
          node {
            src
          }
        }
      }
    }
  }
}
''';

  static String getRelativeProducts = '''
    query(\$query: String, \$pageSize: Int) {
      shop {
        products(first: \$pageSize, query: \$query, sortKey: PRODUCT_TYPE) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              title
              vendor
              description
              availableForSale
              productType
              onlineStoreUrl
              options {
                id
                name
                values
              }
              variants(first: 250) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    id
                    title
                    availableForSale
                    selectedOptions {
                      name
                      value
                    }
                    image(maxHeight: 500, maxWidth: 350) {
                      src
                    }
                    price
                    compareAtPrice
                  }
                }
              }
              images(first: 250, maxHeight: 500, maxWidth: 350) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    src
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String getProductByCollection = '''
    query(\$categoryId: ID!, \$pageSize: Int, \$cursor: String) {
      node(id: \$categoryId) {
        id
        ... on Collection {
          title
          products(first: \$pageSize, after: \$cursor) {
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
            edges {
              cursor
              node {
                id
                title
                vendor
                description
                availableForSale
                productType
                onlineStoreUrl
                collections(first: 1) {
                  pageInfo {
                    hasNextPage
                    hasPreviousPage
                  }
                  edges {
                    node {
                      id
                    }
                  }
                }
                options {
                  id
                  name
                  values
                }
                variants(first: 250) {
                  pageInfo {
                    hasNextPage
                    hasPreviousPage
                  }
                  edges {
                    node {
                      id
                      title
                      availableForSale
                      selectedOptions {
                        name
                        value
                      }
                      image(maxHeight: 500, maxWidth: 350) {
                        src
                      }
                      priceV2 {
                        amount
                        currencyCode
                      }
                      compareAtPriceV2 {
                        amount
                        currencyCode
                      }
                    }
                  }
                }
                images(first: 250, maxHeight: 500, maxWidth: 350) {
                  pageInfo {
                    hasNextPage
                    hasPreviousPage
                  }
                  edges {
                    node {
                      src
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String getRelatedByCollection = '''
    query(\$query: String, \$pageSize: Int) {
      shop {
        products(first: \$pageSize, query: \$query, sortKey: PRODUCT_TYPE) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              title
              vendor
              description
              availableForSale
              productType
              onlineStoreUrl
              options {
                id
                name
                values
              }
              variants(first: 250) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    id
                    title
                    availableForSale
                    selectedOptions {
                      name
                      value
                    }
                    image(maxHeight: 500, maxWidth: 350) {
                      src
                    }
                    price
                    compareAtPrice
                  }
                }
              }
              images(first: 250, maxHeight: 500, maxWidth: 350) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    src
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String getCheckout = '''
    query(\$checkoutId: ID!) {
      node(id: \$checkoutId) {
        ... on Checkout {
          id
          completedAt
        }
      }
    }
  ''';

  static String createCheckout = '''
  mutation checkoutCreate(\$input: CheckoutCreateInput!) {
  checkoutCreate(input: \$input) {
    checkout {
      id
      webUrl
      subtotalPrice
      totalTax
      totalPrice
      paymentDue
      lineItems(first: 250) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            node {
              id
              title
              quantity
              variant {
                title
                image(maxHeight: 500, maxWidth: 350) {
                  src
                }
                price
                selectedOptions {
                  name
                  value
                }
                product {
                  id
                  title
                  description
                  availableForSale
                  productType
                  onlineStoreUrl
                  options {
                    id
                    name
                    values
                  }
                  variants(first: 250) {
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                    edges {
                      node {
                        id
                        title
                        availableForSale
                        selectedOptions {
                          name
                          value
                        }
                        image(maxHeight: 500, maxWidth: 350) {
                          src
                        }
                        price
                        compareAtPrice
                      }
                    }
                  }
                  images(first: 250, maxHeight: 500, maxWidth: 350) {
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                    edges {
                      node {
                        src
                      }
                    }
                  }
                }
              }
          }
        }
      }
      
    }
    checkoutUserErrors {
      code
      field
      message
    }
  }
}
  ''';

  static String updateCheckout = '''
    mutation checkoutLineItemsReplace(
      \$lineItems: [CheckoutLineItemInput!]!
      \$checkoutId: ID!
    ) {
      checkoutLineItemsReplace(lineItems: \$lineItems, checkoutId: \$checkoutId) {
        userErrors {
          field
          message
        }
        checkout {
          id
          webUrl
          totalPrice
          subtotalPrice
          paymentDue
          lineItems(first: 250) {
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
            edges {
              node {
                id
                title
                quantity
                variant {
                  title
                  image(maxHeight: 500, maxWidth: 350) {
                    src
                  }
                  price
                  selectedOptions {
                    name
                    value
                  }
                  product {
                    id
                    title
                    description
                    availableForSale
                    productType
                    onlineStoreUrl
                    options {
                      id
                      name
                      values
                    }
                    variants(first: 250) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          id
                          title
                          availableForSale
                          selectedOptions {
                            name
                            value
                          }
                          image(maxHeight: 500, maxWidth: 350) {
                            src
                          }
                          price
                          compareAtPrice
                        }
                      }
                    }
                    images(first: 250, maxHeight: 500, maxWidth: 350) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          src
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String updateShippingAddress = '''
    mutation checkoutShippingAddressUpdateV2(\$shippingAddress: MailingAddressInput!, \$checkoutId: ID!) {
      checkoutShippingAddressUpdateV2(shippingAddress: \$shippingAddress, checkoutId: \$checkoutId) {
        userErrors {
          field
          message
        }
        checkout {
          id
          webUrl
          subtotalPrice
          totalTax
          totalPrice
          paymentDue
          shippingAddress {
            address1
            address2
            city
            firstName
            id
            lastName
            zip
            phone
            name
            latitude
            longitude
            province
            country
            countryCode
          }
          availableShippingRates {
            ready
            shippingRates {
              handle
              price
              title
            }
          }
          shippingLine {
            price
            title
            handle
          }
          taxExempt
          taxesIncluded
          totalPriceV2 {
            amount
          }
          totalTaxV2 {
            amount
          }
          paymentDueV2 {
            amount
          }
          lineItems(first: 250) {
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
            edges {
              node {
                id
                title
                quantity
                variant {
                  title
                  image(maxHeight:500, maxWidth: 350) {
                    src
                  }
                  price
                  selectedOptions {
                    name
                    value
                  }
                  product {
                    id
                    title
                    description
                    availableForSale
                    productType
                    onlineStoreUrl
                    options {
                      id
                      name
                      values
                    }
                    variants(first: 250) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          id
                          title
                          availableForSale
                          selectedOptions {
                            name
                            value
                          }
                          image(maxHeight: 500, maxWidth: 350) {
                            src
                          }
                          price
                          compareAtPrice
                        }
                      }
                    }
                    images(first: 250, maxHeight: 500, maxWidth: 350) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          src
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String updateShippingLine = '''
    mutation checkoutShippingLineUpdate(\$shippingRateHandle: String!, \$checkoutId: ID!) {
      checkoutShippingLineUpdate(shippingRateHandle: \$shippingRateHandle, checkoutId: \$checkoutId) {
        userErrors {
          field
          message
        }
        checkout {
          id
          webUrl
          subtotalPrice
          totalTax
          totalPrice
          paymentDue
          shippingLine {
            price
            title
            handle
          }
          lineItems(first: 250) {
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
            edges {
              node {
                id
                title
                quantity
                variant {
                  title
                  image(maxHeight: 500, maxWidth: 350) {
                    src
                  }
                  price
                  selectedOptions {
                    name
                    value
                  }
                  product {
                    id
                    title
                    description
                    availableForSale
                    productType
                    onlineStoreUrl
                    options {
                      id
                      name
                      values
                    }
                    variants(first: 250) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          id
                          title
                          availableForSale
                          selectedOptions {
                            name
                            value
                          }
                          image(maxHeight: 500, maxWidth: 350) {
                            src
                          }
                          price
                          compareAtPrice
                        }
                      }
                    }
                    images(first: 250, maxHeight: 500, maxWidth: 350) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          src
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String applyCoupon = '''
    mutation checkoutDiscountCodeApplyV2(\$discountCode: String!, \$checkoutId: ID!) {
      checkoutDiscountCodeApplyV2(discountCode: \$discountCode, checkoutId: \$checkoutId) {
          userErrors {
          field
          message
        }
        checkout {
          id
          webUrl
          totalPrice
          subtotalPrice
          paymentDue
          lineItems(first: 250) {
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
            edges {
              node {
                id
                title
                quantity
                variant {
                  title
                  image(maxHeight: 500, maxWidth: 350) {
                    src
                  }
                  price
                  selectedOptions {
                    name
                    value
                  }
                  product {
                    id
                    title
                    description
                    availableForSale
                    productType
                    onlineStoreUrl
                    options {
                      id
                      name
                      values
                    }
                    variants(first: 250) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          id
                          title
                          availableForSale
                          selectedOptions {
                            name
                            value
                          }
                          image(maxHeight: 500, maxWidth: 350) {
                            src
                          }
                          price
                          compareAtPrice
                        }
                      }
                    }
                    images(first: 250, maxHeight: 500, maxWidth: 350) {
                      pageInfo {
                        hasNextPage
                        hasPreviousPage
                      }
                      edges {
                        node {
                          src
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    ''';

  static String removeCoupon = '''
    mutation checkoutDiscountCodeRemove(\$checkoutId: ID!) {
      checkoutDiscountCodeRemove(checkoutId: \$checkoutId) {
        userErrors {
          field
          message
        }
        checkout {
          id
          webUrl
          totalPrice
          subtotalPrice
          paymentDue
        }
      }
    }
    ''';

  static String checkoutLinkUser = '''
    mutation checkoutCustomerAssociateV2(\$checkoutId: ID!, \$customerAccessToken: String!) {
    checkoutCustomerAssociateV2(checkoutId: \$checkoutId, customerAccessToken: \$customerAccessToken) {
      checkoutUserErrors {
        field
        message
      }
      customer {
        id
        email
      }
      checkout {
      id
      webUrl
      subtotalPrice
      totalTax
      totalPrice
      paymentDue
      lineItems(first: 250) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            node {
              id
              title
              quantity
              variant {
                title
                image(maxHeight: 500, maxWidth: 350) {
                  src
                }
                price
                selectedOptions {
                  name
                  value
                }
                product {
                  id
                  title
                  description
                  availableForSale
                  productType
                  onlineStoreUrl
                  options {
                    id
                    name
                    values
                  }
                  variants(first: 250) {
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                    edges {
                      node {
                        id
                        title
                        availableForSale
                        selectedOptions {
                          name
                          value
                        }
                        image(maxHeight: 500, maxWidth: 350) {
                          src
                        }
                        price
                        compareAtPrice
                      }
                    }
                  }
                  images(first: 250, maxHeight: 500, maxWidth: 350) {
                    pageInfo {
                      hasNextPage
                      hasPreviousPage
                    }
                    edges {
                      node {
                        src
                      }
                    }
                  }
                }
              }
          }
        }
      }
      
    }
  }
}
  ''';

  static String createCustomer = '''
    mutation customerCreate(\$input: CustomerCreateInput!) {
      customerCreate(input: \$input) {
        userErrors {
          field
          message
        }
        customer {
          id
          email
          firstName
          lastName
          phone
        }
      }
    }
  ''';

  static String customerUpdate = '''
    mutation customerUpdate(\$customerAccessToken: String!, \$customer: CustomerUpdateInput!) {
    customerUpdate(customerAccessToken: \$customerAccessToken, customer: \$customer) {
      customer {
        id
      }
      customerAccessToken {
        accessToken
        expiresAt
      }
      customerUserErrors {
        code
        field
        message
      }
    }
  }
  ''';

  static String createCustomerToken = '''
    mutation customerAccessTokenCreate(\$input: CustomerAccessTokenCreateInput!) {
    customerAccessTokenCreate(input: \$input) {
      userErrors {
        field
        message
      }
      customerAccessToken {
        accessToken
        expiresAt
      }
    }
  }
  ''';

  static String renewCustomerToken = '''
    mutation customerAccessTokenRenew(\$customerAccessToken: String!) {
      customerAccessTokenRenew(customerAccessToken: \$customerAccessToken) {
        userErrors {
          field
          message
        }
        customerAccessToken {
          accessToken
          expiresAt
        }
      }
    }
  ''';

  static String getCustomerInfo = '''
    query(\$accessToken: String!) {
      customer(customerAccessToken: \$accessToken) {
        id
        email
        createdAt
        displayName
        phone
        firstName
        lastName
        defaultAddress {
          address1
          address2
          city
          firstName
          id
          lastName
          zip
          phone
          name
          latitude
          longitude
          province
          country
          countryCode
        }
        addresses(first: 10) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            node {
              address1
              address2
              city
              firstName
              id
              lastName
              zip
              phone
              name
              latitude
              longitude
              province
              country
              countryCode
            }
          }
        }
      }
    }
  ''';

  static String getPaymentSettings = '''
    query {
      shop {
        paymentSettings {
          cardVaultUrl
          acceptedCardBrands
          countryCode
          currencyCode
          shopifyPaymentsAccountId
          supportedDigitalWallets
        }
      }
    }
  ''';

  static String checkoutWithCreditCard = '''
    mutation checkoutCompleteWithCreditCardV2(\$checkoutId: ID!, \$payment: CreditCardPaymentInputV2!) {
      checkoutCompleteWithCreditCardV2(checkoutId: \$checkoutId, payment: \$payment) {
        userErrors {
          field
          message
        }
        checkout {
          id
        }
        payment {
          id
          amountV2 {
            amount
          }
        }
      }
    }
  ''';

  static String checkoutWithFree = '''
    mutation checkoutCompleteFree(\$checkoutId: ID!) {
      checkoutCompleteFree(checkoutId: \$checkoutId) {
        userErrors {
          field
          message
        }
        checkout {
          id
        }
        payment {
          id
        }
      }
    }
  ''';

  static String getOrder = '''
    query(\$cursor: String, \$pageSize: Int, \$customerAccessToken: String!) {
      customer(customerAccessToken: \$customerAccessToken) {
        orders(first: \$pageSize, after: \$cursor) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              processedAt
              orderNumber
              totalPrice
              statusUrl
              totalTaxV2 {
                amount
              }
              subtotalPriceV2 {
                amount
              }
              shippingAddress {
                address1
                address2
                city
                company
                country
                firstName
                id
                lastName
                zip
                provinceCode
                phone
                province
                name
                longitude
                latitude
                lastName
              }
              lineItems(first: \$pageSize) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    quantity
                    title
                    variant {
                      title
                      image(maxHeight: 500, maxWidth: 350) {
                        src
                      }
                      price
                      selectedOptions {
                        name
                        value
                      }
                      product {
                        id
                        title
                        description
                        availableForSale
                        productType
                        onlineStoreUrl
                        options {
                          id
                          name
                          values
                        }
                        variants(first: 250) {
                          pageInfo {
                            hasNextPage
                            hasPreviousPage
                          }
                          edges {
                            node {
                              id
                              title
                              availableForSale
                              selectedOptions {
                                name
                                value
                              }
                              image(maxHeight: 500, maxWidth: 350) {
                                src
                              }
                              price
                              compareAtPrice
                            }
                          }
                        }
                        images(first: 250, maxHeight: 500, maxWidth: 350) {
                          pageInfo {
                            hasNextPage
                            hasPreviousPage
                          }
                          edges {
                            node {
                              src
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static String getArticle = '''
    query(\$cursor: String, \$pageSize: Int) {
      shop {
        articles(first: \$pageSize, after: \$cursor) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              url
              title
              excerpt
              authorV2 {
                name
              }
              id
              content
              contentHtml
              image(maxHeight: 1600, maxWidth: 750) {
                transformedSrc
              }
              publishedAt
            }
          }
        }
      }
    }
  ''';
}
