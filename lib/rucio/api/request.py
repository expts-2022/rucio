# Copyright European Organization for Nuclear Research (CERN)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Mario Lassnig, <mario.lassnig@cern.ch>, 2013-2014

from rucio.api import permission
from rucio.common import exception
from rucio.core import request


def queue_requests(requests, issuer):
    """
    Submit transfer or deletion requests on destination RSEs for data identifiers.

    :param requests: List of dictionaries containing 'scope', 'name', 'dest_rse_id', 'request_type', 'attributes'
    :param issuer: Issuing account as a string.
    :returns: List of Request-IDs as 32 character hex strings
    """

    kwargs = {'requests': requests, 'issuer': issuer}
    if not permission.has_permission(issuer=issuer, action='queue_requests', kwargs=kwargs):
        raise exception.AccessDenied('%(issuer)s can not queue request' % locals())

    return request.queue_requests(requests)


def submit_deletion(url, issuer, account):
    """
    Submit a deletion request to a deletiontool.

    :param url: URL acceptable to deletiontool as a string.
    :param issuer: Issuing account as a string.
    :param account: Account identifier as a string.
    :returns: Deletiontool external ID.
    """

    kwargs = {'account': account, 'issuer': issuer, 'url': url}
    if not permission.has_permission(issuer=issuer, action='submit_deletion', kwargs=kwargs):
        raise exception.AccessDenied('%(account)s can not delete' % locals())

    return request.submit_deletion(url)


def submit_transfer(request_id, src_urls, dest_urls, transfertool, issuer, account, metadata={}):
    """
    Submit a transfer request to a transfertool.

    :param request_id: Associated request identifier as a string.
    :param src_urls: Source URL acceptable to transfertool as a list of strings.
    :param dest_urls: Destination URL acceptable to transfertool as a list of strings.
    :param transfertool: Transfertool as a string.
    :param issuer: Issuing account as a string.
    :param account: Account identifier as a string.
    :param metadata: Metadata key/value pairs as a dictionary.
    :returns: Transfertool external ID.
    """

    kwargs = {'account': account, 'issuer': issuer, 'request_id': request_id, 'src_urls': src_urls, 'dest_urls': dest_urls, 'transfertool': transfertool, 'metadata': metadata}
    if not permission.has_permission(issuer=issuer, action='submit_transfer', kwargs=kwargs):
        raise exception.AccessDenied('%(account)s cannot submit a transfer with %s(transfertool)s from %(src_urls)s to %(dest_urls)s' % locals())

    return request.submit_transfer(request_id, src_urls=src_urls, dest_urls=dest_urls, transfertool=transfertool, metadata=metadata)


def query_request(request_id, issuer, account):
    """
    Query the status of a request.

    :param request_id: Request-ID as a 32 character hex string.
    :param issuer: Issuing account as a string.
    :param account: Account identifier as a string.
    :returns: Request status information as a dictionary.
    """

    kwargs = {'account': account, 'issuer': issuer, 'request_id': request_id}
    if not permission.has_permission(issuer=issuer, action='query_request', kwargs=kwargs):
        raise exception.AccessDenied('%(account)s cannot query request %s(request_id)s' % locals())

    return request.query_request(request_id)


def cancel_request(request_id, issuer, account):
    """
    Cancel a request.

    :param request_id: Request Identifier as a 32 character hex string.
    :param issuer: Issuing account as a string.
    :param account: Account identifier as a string.
    """

    kwargs = {'account': account, 'issuer': issuer, 'request_id': request_id}
    if not permission.has_permission(issuer=issuer, action='cancel_request_', kwargs=kwargs):
        raise exception.AccessDenied('%(account)s cannot cancel request %s(request_id)s' % locals())

    return request.cancel_request(request_id)


def cancel_request_did(scope, name, dest_rse, request_type, issuer, account):
    """
    Cancel a request based on a DID and request type.

    :param scope: Data identifier scope as a string.
    :param name: Data identifier name as a string.
    :param dest_rse: RSE name as a string.
    :param request_type: Type of the request as a string.
    :param issuer: Issuing account as a string.
    :param account: Account identifier as a string.
    """

    kwargs = {'account': account, 'issuer': issuer}
    if not permission.has_permission(issuer=issuer, action='cancel_request_did', kwargs=kwargs):
        raise exception.AccessDenied('%(account)s cannot cancel %(request_type)s request for %(scope)s:%(name)s' % locals())

    return request.cancel_request_did(scope, name, dest_rse, request_type)


def get_next(request_type, state, issuer, account):
    """
    Retrieve the next request matching the request type and state.

    :param request_type: Type of the request as a string.
    :param state: State of the request as a string.
    :param issuer: Issuing account as a string.
    :param account: Account identifier as a string.
    :returns: Request as a dictionary.
    """

    kwargs = {'account': account, 'issuer': issuer, 'request_type': request_type, 'state': state}
    if not permission.has_permission(issuer=issuer, action='get_next', kwargs=kwargs):
        raise exception.AccessDenied('%(account)s cannot get the next request of type %(request_type)s in state %(state)s' % locals())

    return request.get_next(request_type, state)
